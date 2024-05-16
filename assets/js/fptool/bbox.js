const BBox = { centerRelative, pointRelative, center, topLeft, getBoundingClientSvgRect };

export default BBox;

// ---

import Vector from "./vectors.js";

function centerRelative(element, relativeToElement) {
    let elementBBox = element.getBoundingClientRect();
    let point = BBox.center(elementBBox);

    return BBox.pointRelative(point, relativeToElement)
}

function topLeft(element, relativeToElement) {
    let bbox = element.getBoundingClientRect();
    return pointRelative({ x: bbox.left, y: bbox.top }, relativeToElement);
}

function pointRelative(point, relativeToElement, offset = { x: 0, y: 0 }) {
    let relativeBBox = relativeToElement.getBoundingClientRect();
    let relativeTopLeft = { x: relativeBBox.left, y: relativeBBox.top }

    let temp = Vector.sub(point, relativeTopLeft)

    return Vector.sub(temp, offset)
}

function center(bbox) {
    return { x: (bbox.left + bbox.right) / 2, y: (bbox.top + bbox.bottom) / 2 };
}



function getBoundingClientSvgRect(element, svg) {
    let relativeBBox = svg.getBoundingClientRect();
    const domRect = element.getBoundingClientRect();
    let svgRect = svg.createSVGRect();

    svgRect.x = domRect.x - relativeBBox.left;
    svgRect.y = domRect.y - relativeBBox.top;
    svgRect.width = domRect.width;
    svgRect.height = domRect.height;

    return svgRect;
}
