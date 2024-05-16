const Vector = {
    fromAngle,
    getAngle,
    fromPoints,
    scalarMul,
    cross,
    dot,
    add,
    sub,
    len,
    isCRightOfAB,
    normal,
    distance,
    normalize,
    getAngleDeg,
    orthogonalProjectionLen,
    projectPointOntoLine
};

export default Vector;

function orthogonalProjectionLen(projectV, ontoV) {
    let ontoVlen = Vector.len(ontoV)
    return Vector.dot(projectV, ontoV) / ontoVlen
}

function projectPointOntoLine(projectPoint, ontoLine) {
    let ontoV = Vector.fromPoints(ontoLine.p1, ontoLine.p2)
    let ontoDirV = Vector.normalize(ontoV)
    let projectV = Vector.fromPoints(ontoLine.p1, projectPoint)
    let projectionLen = Vector.orthogonalProjectionLen(projectV, ontoV)
    return Vector.add(ontoLine.p1, Vector.scalarMul(ontoDirV, projectionLen))
}

function fromAngle(angle) {
    return {
        x: Math.cos(angle * Math.PI / 180),
        y: Math.sin(angle * Math.PI / 180)
    };
}

function getAngle(v1, v2) {
    return Math.atan2(v2.y, v2.x) - Math.atan2(v1.y, v1.x);
}

function getAngleDeg(v1, v2) {
    return getAngle(v1, v2) * 180 / Math.PI
}

function fromPoints(p1, p2) {
    return { x: p2.x - p1.x, y: p2.y - p1.y };
}

function scalarMul(v, s) {
    return { x: v.x * s, y: v.y * s };
}

function cross(v1, v2) {
    return v1.x * v2.y - v1.y * v2.x
}

function dot(v1, v2) {
    return v1.x * v2.x + v1.y * v2.y
}

function add(v1, v2) {
    return { x: v1.x + v2.x, y: v1.y + v2.y };
}

function sub(v1, v2) {
    return { x: v1.x - v2.x, y: v1.y - v2.y };
}

function len(v) {
    return Math.sqrt(Math.pow(v.x, 2) + Math.pow(v.y, 2));
}

function isCRightOfAB(a, b, c) {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x) < 0;
}

function distance(a, b) {
    return Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
}

function normal(v) {
    return { x: -v.y, y: v.x }
}

function normalize(v) {
    return scalarMul(v, 1 / len(v))
}
