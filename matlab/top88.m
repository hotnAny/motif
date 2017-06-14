function top88(trial, args)
    %% [xac] input data cleansing
    disp(args)
    nelx = str2double(args(2));
    nely = str2double(args(3));
    volfrac = str2double(args(4));
    penal = str2double(args(5));
    rmin = str2double(args(6));
    ft = str2double(args(7));
    maxloop = str2double(args(8));
    fixeddofs = str2num(char(args(9)));
    loadnodes = str2num(char(args(10)));
    loadvalues = str2num(char(args(11)));
    actvelms = str2num(char(args(12)));
    favelms = str2num(char(args(13)));
    pasvelms = str2num(char(args(14)));
    distfield = str2num(char(args(15)));
    isadding = size(distfield) == [0, 0];
    debugging = str2num(char(args(16)));
    %% [xac] mass transport
    niters = 16;
    lambda = 0.5;
    decay = 0.95;
    optmove = 0.2;
    massmove = optmove + 0.1;
    minmove = optmove - 0.1;
    eps = 0.001;
    %% MATERIAL PROPERTIES
    E0 = 1;
    Emin = 1e-9;
    nu = 0.3;
    %% PREPARE FINITE ELEMENT ANALYSIS
    A11 = [12  3 -6 -3;  3 12  3  0; -6  3 12 -3; -3  0 -3 12];
    A12 = [-6 -3  0  3; -3 -6 -3 -6;  0 -3 -6  3;  3 -6  3 -6];
    B11 = [-4  3 -2  9;  3 -4 -9  4; -2 -9 -4 -3;  9  4 -3 -4];
    B12 = [ 2 -3  4 -9; -3  2  9 -2;  4  9  2  3; -9 -2  3  2];
    KE = 1/(1-nu^2)/24*([A11 A12;A12' A11]+nu*[B11 B12;B12' B11]);
    nodenrs = reshape(1:(1+nelx)*(1+nely),1+nely,1+nelx);
    edofVec = reshape(2*nodenrs(1:end-1,1:end-1)+1,nelx*nely,1);
    edofMat = repmat(edofVec,1,8)+repmat([0 1 2*nely+[2 3 0 1] -2 -1],nelx*nely,1);
    iK = reshape(kron(edofMat,ones(8,1))',64*nelx*nely,1);
    jK = reshape(kron(edofMat,ones(1,8))',64*nelx*nely,1);
    % DEFINE LOADS AND SUPPORTS (HALF MBB-BEAM)
%     F = sparse(2*nelx*(nely+1)+1,1,-1,2*(nely+1)*(nelx+1),1); % ORIGINAL: 
    F = sparse(loadnodes, ones(size(loadnodes)), loadvalues, 2*(nely+1)*(nelx+1),1);
    U = zeros(2*(nely+1)*(nelx+1),1);
    U0 = U;
%     fixeddofs = union([1:1:2*(nely+1)],[2*(nelx+1)*(nely+1)]); % ORIGINAL
    fixeddofs = union(fixeddofs, [2*(nelx+1)*(nely+1)]);
    alldofs = [1:2*(nely+1)*(nelx+1)];
    freedofs = setdiff(alldofs,fixeddofs);
    %% [xac] setup Stress Analysis
    L=1;
    B = (1/2/L)*[-1 0 1 0 1 0 -1 0; 0 -1 0 -1 0 1 0 1; -1 -1 -1 1 1 1 1 -1];
    DE = (1/(1-nu^2))*[1 nu 0; nu 1 0; 0 0 (1-nu)/2];
    kernel_size = floor(log(max(nelx, nely)/2)) * 2 + 1;
    gaussian = fspecial('gaussian', [kernel_size,kernel_size]);
    %% PREPARE FILTER
    iH = ones(nelx*nely*(2*(ceil(rmin)-1)+1)^2,1);
    jH = ones(size(iH));
    sH = zeros(size(iH));
    k = 0;
    for i1 = 1:nelx
      for j1 = 1:nely
        e1 = (i1-1)*nely+j1;
        for i2 = max(i1-(ceil(rmin)-1),1):min(i1+(ceil(rmin)-1),nelx)
          for j2 = max(j1-(ceil(rmin)-1),1):min(j1+(ceil(rmin)-1),nely)
            e2 = (i2-1)*nely+j2;
            k = k+1;
            iH(k) = e1;
            jH(k) = e2;
            sH(k) = max(0,rmin-sqrt((i1-i2)^2+(j1-j2)^2));
          end
        end
      end
    end
    H = sparse(iH,jH,sH);
    Hs = sum(H,2);
    %% INITIALIZE ITERATION
    if isadding
        x = repmat(volfrac,nely,nelx);
    else
        x = eps + max(0, distfield-eps);
    end
    xPhys = x;
    loop = 0;
    change = 1;
    %% START ITERATION [xac] added maxloop
    while change > 0.05 && (loop < maxloop)
      tic
      loop = loop + 1;
      %% FE-ANALYSIS
      sK = reshape(KE(:)*(Emin+xPhys(:)'.^penal*(E0-Emin)),64*nelx*nely,1);
      K = sparse(iK,jK,sK); K = (K+K')/2;
      U(freedofs) = K(freedofs,freedofs)\F(freedofs);
      
      %% [xac] stress
      E = Emin+x(:)'.^penal*(E0-Emin);
      s = (U(edofMat)*(DE*B)').*repmat(E',1,3);
      vms = reshape(sqrt(sum(s.^2,2)-s(:,1).*s(:,2)+2.*s(:,3).^2),nely,nelx);
      vms = conv2(vms, gaussian, 'same');
      % [xac] log the 'before' results
      if loop==1 U0 = U; vms0 = vms; end
      
      %% OBJECTIVE FUNCTION AND SENSITIVITY ANALYSIS
      ce = reshape(sum((U(edofMat)*KE).*U(edofMat),2),nely,nelx);
      c = sum(sum((Emin+xPhys.^penal*(E0-Emin)).*ce));
      dc = -penal*(E0-Emin)*xPhys.^(penal-1).*ce;
      dv = ones(nely,nelx);
      %% FILTERING/MODIFICATION OF SENSITIVITIES
      if ft == 1
        dc(:) = H*(x(:).*dc(:))./Hs./max(1e-3,x(:));
      elseif ft == 2
        dc(:) = H*(dc(:)./Hs);
        dv(:) = H*(dv(:)./Hs);
      end
      %% OPTIMALITY CRITERIA UPDATE OF DESIGN VARIABLES AND PHYSICAL DENSITIES
      l1 = 0; l2 = 1e9; move = 0.2;
      while (l2-l1)/(l1+l2) > 1e-3
        lmid = 0.5*(l2+l1);
        xnew = max(0,max(x-move,min(1,min(x+move,x.*sqrt(-dc./dv/lmid)))));
        if ft == 1
          xPhys = xnew;
        elseif ft == 2
          xPhys(:) = (H*xnew(:))./Hs;
        end
        if sum(xPhys(:)) > volfrac*nelx*nely, l1 = lmid; else l2 = lmid; end
      end
      change = max(abs(xnew(:)-x(:)));
      x = xnew;
      
      %% [xac] post-processing per iteration     
      xPhys(pasvelms) = 0;
      
%       [xac] add structs
       if isadding xPhys(actvelms) = 1; end
      
      %% PRINT RESULTS
      fprintf(' It.:%3i t:%1.3f Obj.:%11.4f Vol.:%7.3f ch.:%7.3f\n',loop,toc,c, ...
        mean(xPhys(:)),change);
      
      %% PLOT DENSITIES
      if debugging
%         colormap(gray); imagesc(1-xPhys); caxis([0 1]); axis equal; axis off; drawnow;
         colormap(flipud(gray));
         subplot(2,1,1); imagesc(x); axis equal off; text(2,-2,'x');
         subplot(2,1,2); imagesc(vms); axis equal off; text(2,-2,'vms'); drawnow;
      end
        
      try dlmwrite(strcat(trial, '_', num2str(loop), '.out'), xPhys); catch ; end
    end

    try 
        dlmwrite(strcat(trial, '_before.dsp'), U0); 
        dlmwrite(strcat(trial, '_after.dsp'), U);
        dlmwrite(strcat(trial, '_before.vms'), vms0); 
        dlmwrite(strcat(trial, '_after.vms'), vms);
    catch; end        
end