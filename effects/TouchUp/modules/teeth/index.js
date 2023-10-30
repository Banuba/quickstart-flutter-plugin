'use strict';

require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

const vertexShader = "modules/teeth/teeth.vert";

const fragmentShader = "modules/teeth/teeth.frag";

const Whitening = "modules/teeth/lut3d_TEETH_medium.png";
const RedMask = "modules/teeth/redmask_new_3.png";


class Teeth {
    constructor() {
        Object.defineProperty(this, "_teeth", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader,
                fragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Camera(),
                    tex_whitening: new modules_scene_index.LUT(Whitening),
                    tex_redmask: new modules_scene_index.Image(RedMask),
                    var_teeth_whitening_strength: new modules_scene_index.Vector4(0),
                },
            }))
        });
        this._teeth.material.uniforms.var_teeth_whitening_strength.subscribe(([strength]) => this._teeth.visible(strength > 0));
        modules_scene_index.add(this._teeth);
    }
    /** Sets the teeth whitening strength from 0 to 1 */
    whitening(strength) {
        if (typeof strength !== "undefined")
            this._teeth.material.uniforms.var_teeth_whitening_strength.value(strength);
        return this._teeth.material.uniforms.var_teeth_whitening_strength.value()[0];
    }
    /** Resets any settings applied */
    clear() {
        this.whitening(0);
    }
}

exports.Teeth = Teeth;
