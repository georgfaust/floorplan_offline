const Lines = { intersect: intersect };

export default Lines;

// ---

import Vector from "./vectors.js";

function intersect(line1, line2) {
    let x_diff = { 
        x: line1.p1.x - line1.p2.x, 
        y: line2.p1.x - line2.p2.x 
    }
    let y_diff = { 
        x: line1.p1.y - line1.p2.y, 
        y: line2.p1.y - line2.p2.y 
    }

    let diff_det = Vector.cross(x_diff, y_diff)

    if (diff_det == 0) {
        return null
    }
    else {
        let d = { 
            x: Vector.cross(line1.p1, line1.p2), 
            y: Vector.cross(line2.p1, line2.p2) 
        }

        return { 
            x: Vector.cross(d, x_diff) / diff_det, 
            y: Vector.cross(d, y_diff) / diff_det 
        }
    }
}