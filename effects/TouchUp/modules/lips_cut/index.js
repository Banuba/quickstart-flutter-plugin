'use strict';


const modules_scene_index = require('../scene/index.js');

const mattVertexShader = "modules/lips_cut/Q0.vert";

const mattFragmentShader = "modules/lips_cut/Q0.frag";

class LipsCut {
    constructor() {
        Object.defineProperty(this, "_face", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.FaceGeometry(), [])
        });
        Object.defineProperty(this, "_cut", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.QuadGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: mattVertexShader,
                fragmentShader: mattFragmentShader,
                uniforms: {
                    tex_camera: new modules_scene_index.Camera(),
                    tex_scene: new modules_scene_index.Scene(),
                    tex_lips_mask: new modules_scene_index.SegmentationMask("LIPS"),
                },
                state: {
                    blending: "ALPHA",
                    backFaces: false
                },
            }))
        });
        this._face.add(this._cut);
        modules_scene_index.add(this._face,this._cut);
    }
    enable() {
        this._cut.material.uniforms.tex_lips_mask.enable();
        this._cut.visible(true);

    }
    clear() {
        this._cut.visible(false);

    }
}

exports.LipsCut = LipsCut;
