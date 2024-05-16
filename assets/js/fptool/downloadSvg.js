const DownloadSvg = { download }
export default DownloadSvg;

// ---

function download() {
    var svgElement = document.getElementById('svg-canvas');
    var serializer = new XMLSerializer();

    var svgBlob = new Blob(
        [serializer.serializeToString(svgElement)], 
        { type: "image/svg+xml;charset=utf-8" }
    );

    var url = URL.createObjectURL(svgBlob);

    var downloadLink = document.createElement("a");
    downloadLink.href = url;
    downloadLink.download = "mySVG.svg";  // Name of the file
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);

    URL.revokeObjectURL(url);
}