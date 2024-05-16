const Item = { init, update }
export default Item;

// ---

import BBox from "./bbox.js"
import Frames from "./frames.js"
import Connector from "./connector.js";
import Vector from "./vectors.js";
import Lines from "./lines.js";

const canvasElement = document.getElementById('canvas');
const svgCanvasElement = document.getElementById('svg-canvas');
const wallsGroup = document.getElementById('walls');
const roomsGroup = document.getElementById('rooms');
// const intersectCircle1 = document.getElementById('debug-marker-circle-1');
// const intersectCircle2 = document.getElementById('debug-marker-circle-2');
// const intersectCircle3 = document.getElementById('debug-marker-circle-3');
// const intersectCircle4 = document.getElementById('debug-marker-circle-4');
// const intersectCircles = [intersectCircle1, intersectCircle2, intersectCircle3, intersectCircle4]

let state = {
    isDragging: false,
    currentElement: null,
    currentPaths: null,
    currentOffset: null,
    highlightedWall: null,
    currentRoom: null
}


function removeHighlight() {
    state.highlightedWall.style.stroke = state.highlightedWall.dataset.cssStroke;
    state.highlightedWall = null;
}

function addHighlight(wall) {
    state.highlightedWall = wall
    state.highlightedWall.dataset.cssStroke = state.highlightedWall.style.stroke
    state.highlightedWall.style.stroke = "pink"
}

function setTransform(element, field, value) {
    const UNIT = {
        rotate: "deg"
    }

    transformMap = JSON.parse(element.dataset.transform)
    transformMap[field] = value
    element.dataset.transform = JSON.stringify(transformMap)
    transform = Object.entries(transformMap).map(([key, value]) => `${key}(${value}${UNIT[key] || ""})`).join(" ");
    state.currentElement.style.transform = transform;
}

const droppable = {
    light: ["ceiling", "wall"],
    ssd: ["wall"],
    motor: ["window"],
    frame: ["door"],
}

function canDropHere(element, dropTarget) {
    return droppable[element.dataset.itemType].includes(dropTarget);
}

function setPosition(element, position) {
    element.__position__ = position
    element.style.left = `${position.x}px`;
    element.style.top = `${position.y}px`;
}

function setValidPosition(element, position) {
    element.__lastValidPosition__ = position
    element.__isValidPosition__ = true
    highlightItem(element, "rgba(49, 245, 85, 0.5)")
}

function setInvalidPosition(element) {
    element.__isValidPosition__ = false
    highlightItem(element, "rgba(250, 20, 227, 0.5)")
}

function highlightItem(element, color) {
    element.querySelectorAll("[data-background").forEach(e => e.style.fill = color)
}

function update(itemElement) {
    if (itemElement.dataset.isSelected == "selected") {
        console.log("highlight")
        highlightItem(itemElement, "rgba(252, 236, 3, 0.5)")
    }

    if (itemElement.dataset.itemType === "frame") {
        Frames.createOrUpdateConnectors(itemElement.id)
    }
}

function init(itemElement) {
    itemElement.addEventListener('mousedown', mousedownHandlerFactory(itemElement))
    itemElement.__isValidPosition__ = true

    if (itemElement.dataset.itemType === "frame") {
        Frames.loadFrame(itemElement)
    }
}

function mousedownHandlerFactory(itemElement) {
    return function (e) {
        state.currentElement = itemElement;
        let position = {
            x: state.currentElement.getBoundingClientRect().x,
            y: state.currentElement.getBoundingClientRect().y
        }
        setValidPosition(itemElement, position)

        state.currentElement.__lastValidPosition__ = BBox.pointRelative(position, canvasElement)

        state.currentOffset = Vector.sub({ x: e.clientX, y: e.clientY }, position)
        const connectorsSelector = `[data-is-connector-path][data-target-id="${state.currentElement.id}"]`
        state.currentPaths = document.querySelectorAll(connectorsSelector);

        state.isDragging = true;
        window.addEventListener('mousemove', mousemoveHandler);
        window.addEventListener('mouseup', mouseupHandler);
    }
}

function mousemoveHandler(e) {
    console.log("move")
    // if this was dragged from the toolbar, do NOT move the item but create a clone and use that
    if (state.currentElement.dataset.clone === "do-clone") {
        state.currentElement = state.currentElement.cloneNode(true)
        state.currentElement.removeAttribute("id")
        state.currentElement.dataset.clone = "is-clone"
        state.currentElement.dataset.transform = "{}"
        state.currentElement.classList.remove("relative")
        state.currentElement.classList.add("absolute")
        canvasElement.appendChild(state.currentElement);
    }

    let newPosition = BBox.pointRelative({ x: e.clientX, y: e.clientY }, canvasElement, state.currentOffset)
    let dropTarget = "ceiling"

    if (state.highlightedWall) {
        let wall = loadWall(state.highlightedWall.id)
        let closestPointOnLine = getClosestPointOnWall(newPosition, wall)
        let distance = Vector.distance(closestPointOnLine, newPosition)

        if (distance < 100) {
            // are we at a wall-child (door or window)?
            let offset = Vector.distance(closestPointOnLine, wall.line.p1)
            let child = wall.children.find(c => c.offset < offset && c.offset + c.width > offset)

            if (child) {
                dropTarget = child.type
                closestPointOnLine = Vector.add(wall.line.p1, Vector.scalarMul(wall.dir, child.offset))
            }
            else {
                dropTarget = "wall"
            }

            // TODO actually gives leftOf???
            let isLeftOfWall = Vector.isCRightOfAB(wall.line.p1, wall.line.p2, newPosition);
            let rotate = null;
            let thicknessCorrection = null;

            if (!isLeftOfWall) {
                rotate = wall.angle;
                // NOTE: the 5 is needed to make the item still collide with the wall
                //       --> therefore all items need a 5px padding!
                thicknessCorrection = wall.thickness / 2 - 5
            }
            else {
                rotate = wall.angle + 180;
                thicknessCorrection = -wall.thickness / 2 + 5
            }

            thicknessCorrectionV = Vector.scalarMul(wall.normal, thicknessCorrection)
            // move top-center to the point as top-center is the rot-point
            // TODO get rid of magic number (it is 50/2 where 50 is the size of all items)
            let correctionV = Vector.sub(thicknessCorrectionV, { x: 25, y: 0 })

            newPosition = Vector.add(closestPointOnLine, correctionV)
            state.currentElement.__movingAlongWall__ = true
            setTransform(state.currentElement, "rotate", rotate)
        }
    }
    else {
        setTransform(state.currentElement, "rotate", 0)
        state.currentElement.__movingAlongWall__ = false
    }

    if (canDropHere(state.currentElement, dropTarget)) {
        setValidPosition(state.currentElement, newPosition)
    }
    else {
        setInvalidPosition(state.currentElement)
    }

    setPosition(state.currentElement, newPosition)

    let intersectWith = BBox.getBoundingClientSvgRect(state.currentElement, svgCanvasElement);
    let wall_intersections = svgCanvasElement.getIntersectionList(intersectWith, wallsGroup);
    wall_intersections = [...wall_intersections].filter(e => e.dataset.elementType === "wall")

    if (wall_intersections.length == 1) {
        if (state.highlightedWall && state.highlightedWall.id != wall_intersections[0].id) {
            removeHighlight()
        }
        if (!state.highlightedWall) {
            addHighlight(wall_intersections[0])
        }
    } else {
        if (state.highlightedWall) {
            removeHighlight();
        }
    }

    intersectWith = BBox.getBoundingClientSvgRect(state.currentElement, svgCanvasElement);
    let room_intersections = svgCanvasElement.getIntersectionList(intersectWith, roomsGroup);
    room_intersections = [...room_intersections].filter(e => e.dataset.elementType === "room")
    if (room_intersections.length == 1) {
        if (state.currentRoom != room_intersections[0]) {
            state.currentRoom = room_intersections[0]
            // console.log("NEW ROOM", state.currentRoom.id, state.currentRoom.dataset.walls)
        }
    }
    else {
        state.currentRoom = null
    }

    if (state.currentRoom) {
        let walls = JSON.parse(state.currentRoom.dataset.walls)
        walls.forEach((w, index) => createOrUpdateAidLine(w, index))
    }

    // TODO rename path->connector
    state.currentPaths.forEach(pathElement => {
        let buttonElement = document.getElementById(pathElement.dataset.buttonId);
        let frame = Frames.getFrame(pathElement.dataset.frameId);

        Connector.createOrUpdatePath(
            frame,
            buttonElement,
            state.currentElement,
            pathElement.id,
            canvasElement
        );
    });

    if (state.currentElement.dataset.itemType === "frame") {
        Frames.createOrUpdateConnectors(state.currentElement.id)
    }
}

function mouseupHandler(e) {
    if (state.currentElement) {
        state.currentElement.querySelectorAll("[data-background").forEach(e => e.style.fill = "white")
        let is_new = state.currentElement.dataset.clone == "is-clone"
        let element = state.highlightedWall?.id
        let element_type = state.highlightedWall?.dataset.elementType

        if (state.highlightedWall) {
            removeHighlight();
        }

        let doSendUpdate = true
        if (!state.currentElement.__isValidPosition__) {
            if (is_new) {
                state.currentElement.remove()
                doSendUpdate = false
            }
            else {
                setPosition(state.currentElement, state.currentElement.__lastValidPosition__)
            }
        }

        if (doSendUpdate) {
            let params = {
                is_new: is_new,
                item_id: state.currentElement.id,
                item_type: state.currentElement.dataset.itemType,
                pos: state.currentElement.__position__,
                element: element,
                element_type: element_type,
                transform: JSON.parse(state.currentElement.dataset.transform)
            }
            pushEventToServer("item-update", params)
        }
    }

    window.removeEventListener('mousemove', mousemoveHandler);
    window.removeEventListener('mouseup', mouseupHandler);

    state.currentOffset = null;
    state.isDragging = false;
    state.currentElement = null;
    state.currentPaths = null;
}

// TODO load on startup
// function loadWalls() {
//     document.querySelectorAll('[data-element-type="wall"]')
// }

function loadWall(lineElementId) {
    let lineElement = document.getElementById(lineElementId);
    let children = document.querySelectorAll(`[data-wall-ref=${lineElementId}]`)
    children = Array.from(children).map(child => {
        return {
            offset: parseFloat(child.dataset.offset),
            width: parseFloat(child.dataset.width),
            id: child.id,
            type: child.dataset.elementType
        }
    })

    const P1 = { x: lineElement.x1.baseVal.value, y: lineElement.y1.baseVal.value }
    const P2 = { x: lineElement.x2.baseVal.value, y: lineElement.y2.baseVal.value }

    const directionV = Vector.normalize(Vector.fromPoints(P1, P2));

    return {
        children: children,
        line: { p1: P1, p2: P2 },
        angle: parseFloat(lineElement.dataset.angle),
        thickness: parseFloat(lineElement.dataset.thickness),
        normal: Vector.normal(directionV),
        dir: directionV,
        min: { x: Math.min(P1.x, P2.x), y: Math.min(P1.y, P2.y) },
        max: { x: Math.max(P1.x, P2.x), y: Math.max(P1.y, P2.y) }
    }
}

function getClosestPointOnWall(point, wall, relativeToElement) {
    point = relativeToElement ? BBox.pointRelative(point, relativeToElement) : point;

    let normalLine = { p1: point, p2: Vector.add(point, wall.normal) }
    let intersectP = Lines.intersect(normalLine, wall.line);
    if (intersectP.x < wall.min.x) intersectP.x = wall.min.x;
    if (intersectP.x > wall.max.x) intersectP.x = wall.max.x;
    if (intersectP.y < wall.min.y) intersectP.y = wall.min.y;
    if (intersectP.y > wall.max.y) intersectP.y = wall.max.y;

    return intersectP;
}

function createOrUpdateAidLine(wall, wallIndex) {
    let aidLineId = `aidLine-${state.currentElement.id}-${wallIndex}`
    let pathId = aidLineId + "path"

    let itemCenterPoint = BBox.centerRelative(state.currentElement, canvasElement)
    let projectionPoint = Vector.projectPointOntoLine(itemCenterPoint, wall)
    let aidLineV = Vector.fromPoints(projectionPoint, itemCenterPoint)
    let measurement = Vector.len(aidLineV)
    let aidLineAngle = Vector.getAngleDeg(aidLineV, { x: 1, y: 0 })

    // intersectCircles[wallIndex].setAttribute("cx", projectionPoint.x)
    // intersectCircles[wallIndex].setAttribute("cy", projectionPoint.y)

    if (aidLineAngle >= -90 && aidLineAngle < 90) {
        let aidLineGroupElement = document.getElementById(aidLineId);
        let pathElement = null;
        let textPathElement = null;

        if (!aidLineGroupElement) {
            aidLineGroupElement = document.createElementNS("http://www.w3.org/2000/svg", "g");
            aidLineGroupElement.setAttribute("id", aidLineId)

            pathElement = document.createElementNS("http://www.w3.org/2000/svg", "path");
            aidLineGroupElement.appendChild(pathElement)
            pathElement.setAttribute("id", pathId);
            pathElement.setAttribute("fill", "none");
            pathElement.setAttribute('stroke', 'blue');
            pathElement.setAttribute('stroke-width', '0.2');
            pathElement.setAttribute('stroke-dasharray', '5 2');

            let textElement = document.createElementNS("http://www.w3.org/2000/svg", "text");
            aidLineGroupElement.appendChild(textElement)
            textElement.setAttribute("font-size", "14px");
            textElement.setAttribute("dy", "-5px");
            // TODO glitches when path gets too short for text!
            // textElement.setAttribute("filter", "url(#svg-text-background")

            textPathElement = document.createElementNS("http://www.w3.org/2000/svg", "textPath");
            textElement.appendChild(textPathElement);
            textPathElement.setAttributeNS("http://www.w3.org/1999/xlink", "href", `#${pathId}`);
            textPathElement.setAttribute("startOffset", "20px")

            let aidLines = document.getElementById('aid-lines')
            aidLines.appendChild(aidLineGroupElement);
        }
        else {
            pathElement = document.getElementById(pathId);
            textPathElement = aidLineGroupElement.querySelector("textPath")
        }

        if (measurement > 100) {
            pathElement.setAttribute("d", `M${projectionPoint.x},${projectionPoint.y} L${itemCenterPoint.x},${itemCenterPoint.y}`);
            textPathElement.textContent = `${measurement}cm`;
        }
        else {
            aidLineGroupElement.remove()
        }
    }
}