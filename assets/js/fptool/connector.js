const Connector = { createOrUpdatePath }
export default Connector;

// ---

import Vector from "./vectors.js";
import BBox from "./bbox.js"

function createOrUpdatePath(frame, buttonElement, targetElement, pathId, relativeToElement) {
    const startPoint = BBox.centerRelative(buttonElement, relativeToElement);
    const endPoint = BBox.centerRelative(targetElement, relativeToElement);
    const isTargetRight = Vector.isCRightOfAB(frame.anchor, Vector.add(frame.anchor, frame.inwardsV), endPoint);

    const control1V = Vector.add(startPoint, Vector.scalarMul(frame.rightV, frame.bbox.width * 3))
    let control2V = Vector.add(control1V, Vector.scalarMul(frame.inwardsV, frame.bbox.height * 3))
    if (!isTargetRight) {
        const endPointV = Vector.fromPoints(startPoint, endPoint);
        // TODO should that not be frame.rightV?
        // --> create a debug mode where all helper points and vectors are shown!
        let orthogonalProjectionLen = Vector.orthogonalProjectionLen(endPointV, frame.inwardsV);
        if (orthogonalProjectionLen < Vector.len(control2V)) {
            control2V = endPoint;
        }
    }

    let pathElement = document.getElementById(pathId);

    if (!pathElement) {
        pathElement = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        pathElement.id = pathId;
        pathElement.setAttribute('data-is-connector-path', true);
        pathElement.setAttribute('data-target-id', targetElement.id);
        pathElement.setAttribute('data-frame-id', frame.id);
        pathElement.setAttribute('data-button-id', buttonElement.id);
        pathElement.setAttribute('stroke', 'gray');
        pathElement.setAttribute('stroke-width', '1');
        pathElement.setAttribute('stroke-dasharray', '2 1 2 1');
        pathElement.setAttribute('fill', 'transparent');
        // TODO remove?
        pathElement.dataset.isInitialized = "true"
        document.getElementById('connectors').appendChild(pathElement);
    }
    const pathData = `M ${startPoint.x} ${startPoint.y} C ${control1V.x} ${control1V.y}, ${control2V.x} ${control2V.y}, ${endPoint.x} ${endPoint.y}`;
    pathElement.setAttribute('d', pathData);
}
