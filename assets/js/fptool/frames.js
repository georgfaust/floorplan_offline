const Frames = { loadFrame, getFrame, createOrUpdateConnectors }
export default Frames;

// ---

import Vector from "./vectors.js";
import Connector from "./connector.js";

let frameStore = {};
const canvasElement = document.getElementById('canvas');

function getFrame(frameId) {
    return frameStore[frameId];
}

function loadFrame(frameElement) {
    const bbox = frameElement.getBoundingClientRect();
    const anchor = {
        x: parseFloat(frameElement.dataset.anchorX) || 0,
        y: parseFloat(frameElement.dataset.anchorY) || 0
    };

    const transform = JSON.parse(frameElement.dataset.transform)
    const inwardsV = Vector.fromAngle(transform.rotate + 90);
    const rightV = Vector.fromAngle(transform.rotate + 180);

    const buttonElements = frameElement.querySelectorAll('[data-button-targets]');

    let frame = { id: frameElement.id, bbox, anchor, inwardsV, rightV, buttonElements};
    frameStore[frameElement.id] = frame;

    createOrUpdateConnectors(frame.id)
}

function createOrUpdateConnectors(frameId) {
    frame = getFrame(frameId)
    frame?.buttonElements?.forEach((buttonElement, buttonIndex) => {
        const targetIds = JSON.parse(buttonElement.dataset.buttonTargets);
        targetIds.forEach(targetId => {
            const targetElement = document.getElementById(targetId);

            if (targetElement) {
                Connector.createOrUpdatePath(
                    frame,
                    buttonElement,
                    targetElement,
                    `connector_${frame.id}_${buttonIndex}_${targetElement.id}`,
                    canvasElement
                );
            }
        });
    });
}
