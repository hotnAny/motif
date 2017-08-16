FORTE.sandbox = function () {
    
};

//
//
//
FORTE.GridCanvas.prototype.showDisplacements = function (displacements, width, height) {
    var heatmap = XAC.initMDArray([height, width]);
    var maxDisp = 0;
    for (var j = 0; j < height; j++) {
        for (var i = 0; i < width; i++) {
            //  0---3
            //  |   |
            //  1---2
            var n0 = i * (height + 1) + j;
            var n1 = (i + 1) * (height + 1) + j;
            var n2 = (i + 1) * (height + 1) + j + 1;
            var n3 = i * (height + 1) + j + 1;

            var nodes = [n0, n1, n2, n3];

            var vdisp = {
                x: 0,
                y: 0
            };
            // var dispValue = 0;

            for (node of nodes) {
                vdisp.x += displacements[2 * node];
                vdisp.y += displacements[2 * node + 1];
            }

            vdisp.x /= 4;
            vdisp.y /= 4;

            var dispValue = Math.sqrt(Math.pow(vdisp.x, 2) + Math.pow(vdisp.y, 2));

            if (!isNaN(dispValue)) maxDisp = Math.max(maxDisp, dispValue);
            else console.error('NaN!')
            heatmap[j][i] = dispValue;
        }
        // log(heatmap[j])
    }

    for (var j = 0; j < height; j++) {
        for (var i = 0; i < width; i++) {
            heatmap[j][i] = XAC.getHeatmapColor(heatmap[j][i], maxDisp);
            // log(heatmap[j][i])
        }
    }

    return heatmap;
}