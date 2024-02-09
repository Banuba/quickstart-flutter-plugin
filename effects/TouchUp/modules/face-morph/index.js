'use strict';

require('bnb_js/console');
require('bnb_js/global');
const modules_scene_index = require('../scene/index.js');

let morphs_00_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
let morphs_04_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
let morphs_08_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
let morphs_12_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
let morphs_16_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
let morphs_20_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
let morphs_24_vec4 = new modules_scene_index.Vector4(0., 0., 0., 0.);
const morphs_ktx = "modules/face-morph/morphs.ktx";
const ApplyFragmentShader = "modules/face-morph/apply.frag";
const ApplyVertexShader = "modules/face-morph/apply.vert";
const DrawFragmentShader = "modules/face-morph/draw.frag";
const DrawVertexShader = "modules/face-morph/draw.vert";
const BlurFragmentShader = "modules/face-morph/blur.frag";
const HBlurVertexShader = "modules/face-morph/hblur.vert";
const VBlurVertexShader = "modules/face-morph/vblur.vert";
function WarpTex() {
    const _morph_draw = new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
        vertexShader: DrawVertexShader,
        fragmentShader: DrawFragmentShader,
        uniforms: {
            tex_morphs: new modules_scene_index.Image(morphs_ktx),
            morphs_00: morphs_00_vec4,
            morphs_04: morphs_04_vec4,
            morphs_08: morphs_08_vec4,
            morphs_12: morphs_12_vec4,
            morphs_16: morphs_16_vec4,
            morphs_20: morphs_20_vec4,
            morphs_24: morphs_24_vec4,
        },
        state: {
            backFaces: false,
            colorWrite: true,
            blending: "OFF",
            zWrite: true,
            zTest: true
        },
        instance_count: 9
    }), new modules_scene_index.FaceGeometry(), {
        filtering: "LINEAR",
        width: 0,
        height: 480,
        info: {
            format: "RG16F",
            load: "CLEAR"
        }
    });
    const _morph_blur_h = new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
        vertexShader: HBlurVertexShader,
        fragmentShader: BlurFragmentShader,
        uniforms: {
            tex_src: _morph_draw,
        },
        state: {
            backFaces: true,
        },
    }), new modules_scene_index.PlaneGeometry(), {
        filtering: "LINEAR",
        width: 0,
        height: 480,
        info: {
            format: "RG16F",
            load: "CLEAR"
        }
    });
    const _morph_blur_v = new modules_scene_index.Pass(new modules_scene_index.ShaderMaterial({
        vertexShader: VBlurVertexShader,
        fragmentShader: BlurFragmentShader,
        uniforms: {
            tex_src: _morph_blur_h,
        },
        state: {
            backFaces: true,
        },
    }), new modules_scene_index.PlaneGeometry(), {
        filtering: "LINEAR",
        width: 0,
        height: 480,
        info: {
            format: "RG16F",
            load: "CLEAR"
        }
    });
    return _morph_blur_v;
}
class FaceMorph {
    constructor() {
        Object.defineProperty(this, "_morph_apply", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: new modules_scene_index.Mesh(new modules_scene_index.PlaneGeometry(), new modules_scene_index.ShaderMaterial({
                vertexShader: ApplyVertexShader,
                fragmentShader: ApplyFragmentShader,
                uniforms: {
                    tex_warp: WarpTex(),
                    tex_frame: new modules_scene_index.Scene(),
                },
                state: {
                    backFaces: true,
                },
            }))
        });
        modules_scene_index.add(this._morph_apply);
    }
    /** Set all morph weights, w should be an array with 28 weits in order:
       0 Eyebrows spacing         - Adjusting the space between the eyebrows [-1;1]
       1 Eyebrows height          - Raising/lowering the eyebrows [-1;1]
       2 Eyebrows bend            - Adjusting the bend of the eyebrows [-1;1]
       3 Eyes enlargement         - Enlarging the eyes [0;1]
       4 Eyes rounding            - Adjusting the roundness of the eyes [0;1]
       5 Eyes height              - Raising/lowering the eyes [-1;1]
       6 Eyes spacing             - Adjusting the space between the eyes [-1;1]
       7 Eyes squint              - Making the person squint by adjusting the eyelids [-1;1]
       8 Lower eyelid position    - Raising/lowering the lower eyelid [-1;1]
       9 Lower eyelid size        - Enlarging/shrinking the lower eyelid [-1;1]
      10 Nose length              - Adjusting the nose length [-1;1]
      11 Nose width               - Adjusting the nose width [-1;1]
      12 Nose tip width           - Adjusting the nose tip width [0;1]
      13 Lips height              - Raising/lowering the lips [-1;1]
      14 Lips size                - Adjusting the width and vertical size of the lips [-1;1]
      15 Lips thickness           - Adjusting the thickness of the lips [-1;1]
      16 Mouth size               - Adjusting the size of the mouth [-1;1]
      17 Smile                    - Making a person smile [0;1]
      18 Lips shape               - Adjusting the shape of the lips [-1;1]
      19 Face narrowing           - Narrowing the face [0;1]
      20 Face V-shape             - Shrinking the chin and narrowing the cheeks [0;1]
      21 Cheekbones narrowing     - Narrowing the cheekbones [-1;1]
      22 Cheeks narrowing         - Narrowing the cheeks [0;1]
      23 Jaw narrowing            - Narrowing the jaw [0;1]
      24 Chin shortening          - Decreasing the length of the chin [0;1]
      25 Chin narrowing           - Narrowing the chin [0;1]
      26 Sunken cheeks            - Sinking the cheeks and emphasizing the cheekbones [0;1]
      27 Cheeks and jaw narrowing - Narrowing the cheeks and the jaw [0;1]
    */
    weights(w) {
        morphs_00_vec4.value(w[0], w[1], w[2], w[3]);
        morphs_04_vec4.value(w[4], w[5], w[6], w[7]);
        morphs_08_vec4.value(w[8], w[9], w[10], w[11]);
        morphs_12_vec4.value(w[12], w[13], w[14], w[15]);
        morphs_16_vec4.value(w[16], w[17], w[18], w[19]);
        morphs_20_vec4.value(w[20], w[21], w[22], w[23]);
        morphs_24_vec4.value(w[24], w[25], w[26], w[27]);
    }
    /** Set eyebrows morph params. Params should be a number (only spacing), or object with properties:
        spacing - Adjusting the space between the eyebrows [-1;1]
        height  - Raising/lowering the eyebrows [-1;1]
        bend    - Adjusting the bend of the eyebrows [-1;1]
    **/
    eyebrows(params) {
        if (typeof params === "number")
            morphs_00_vec4.x(params);
        if (typeof params === "object") {
            let array = Object.keys(params);
            array.includes("spacing") && morphs_00_vec4.x(params.spacing);
            array.includes("height") && morphs_00_vec4.y(params.height);
            array.includes("bend") && morphs_00_vec4.z(params.bend);
        }
    }
    /** Set eyes morph params. Params should be a number (only rounding), or object with properties:
        rounding          - Adjusting the roundness of the eyes [0;1]
        enlargement       - Enlarging the eyes [0;1]
        height            - Raising/lowering the eyes [-1;1]
        spacing           - Adjusting the space between the eyes [-1;1]
        squint            - Making the person squint by adjusting the eyelids [-1;1]
        lower_eyelid_pos  - Raising/lowering the lower eyelid [-1;1]
        lower_eyelid_size - Enlarging/shrinking the lower eyelid [-1;1]
    **/
    eyes(params) {
        if (typeof params === "number")
            morphs_04_vec4.x(params);
        if (typeof params === "object") {
            let array = Object.keys(params);
            array.includes("rounding") && morphs_04_vec4.x(params.rounding);
            array.includes("enlargement") && morphs_00_vec4.w(params.enlargement);
            array.includes("height") && morphs_04_vec4.y(params.height);
            array.includes("spacing") && morphs_04_vec4.z(params.spacing);
            array.includes("squint") && morphs_04_vec4.w(params.squint);
            array.includes("lower_eyelid_pos") && morphs_08_vec4.x(params.lower_eyelid_pos);
            array.includes("lower_eyelid_size") && morphs_08_vec4.y(params.lower_eyelid_size);
        }
    }
    /** Set nose morph params. Params should be a number (only width), or object with properties:
        width     - Adjusting the nose width [-1;1]
        length    - Adjusting the nose length [-1;1]
        tip_width - Adjusting the nose tip width [0;1]
    **/
    nose(params) {
        if (typeof params === "number")
            morphs_08_vec4.w(params);
        if (typeof params === "object") {
            let array = Object.keys(params);
            array.includes("width") && morphs_08_vec4.w(params.width);
            array.includes("length") && morphs_08_vec4.z(params.length);
            array.includes("tip_width") && morphs_12_vec4.x(params.tip_width);
        }
    }
    /** Set lips morph params. Params sould be a number (only size), or object with properties:
        size       - Adjusting the width and vertical size of the lips [-1;1]
        height     - Raising/lowering the lips [-1;1]
        thickness  - Adjusting the thickness of the lips [-1;1]
        mouth_size - Adjusting the size of the mouth [-1;1]
        smile      - Making a person smile [0;1]
        shape      - Adjusting the shape of the lips [-1;1]
    **/
    lips(params) {
        if (typeof params === "number")
            morphs_12_vec4.z(params);
        if (typeof params === "object") {
            let array = Object.keys(params);
            array.includes("size") && morphs_12_vec4.z(params.size);
            array.includes("height") && morphs_12_vec4.y(params.height);
            array.includes("thickness") && morphs_12_vec4.w(params.thickness);
            array.includes("mouth_size") && morphs_16_vec4.x(params.mouth_size);
            array.includes("smile") && morphs_16_vec4.y(params.smile);
            array.includes("shape") && morphs_16_vec4.z(params.shape);
        }
    }
    /** Set face morph params. Params sould be a number (only narrowing), or object with properties:
        narrowing            - Narrowing the face [0;1]
        v_shape              - Shrinking the chin and narrowing the cheeks [0;1]
        chekbones_narrowing  - Narrowing the cheekbones [-1;1]
        cheeks_narrowing     - Narrowing the cheeks [0;1]
        jaw_narrowing        - Narrowing the jaw [0;1]
        chin_shortening      - Decreasing the length of the chin [0;1]
        chin_narrowing       - Narrowing the chin [0;1]
        sunken_cheeks        - Sinking the cheeks and emphasizing the cheekbones [0;1]
        cheeks_jaw_narrowing - Narrowing the cheeks and the jaw [0;1]
    **/
    face(params) {
        if (typeof params === "number")
            morphs_16_vec4.w(params);
        if (typeof params === "object") {
            let array = Object.keys(params);
            array.includes("narrowing") && morphs_16_vec4.w(params.narrowing);
            array.includes("v_shape") && morphs_20_vec4.x(params.v_shape);
            array.includes("cheekbones_narrowing") && morphs_20_vec4.y(params.cheekbones_narrowing);
            array.includes("cheeks_narrowing") && morphs_20_vec4.z(params.cheeks_narrowing);
            array.includes("jaw_narrowing") && morphs_20_vec4.w(params.jaw_narrowing);
            array.includes("chin_shortening") && morphs_24_vec4.x(params.chin_shortening);
            array.includes("chin_narrowing") && morphs_24_vec4.y(params.chin_narrowing);
            array.includes("sunken_cheeks") && morphs_24_vec4.z(params.sunken_cheeks);
            array.includes("cheeks_jaw_narrowing") && morphs_24_vec4.w(params.cheeks_jaw_narrowing);
        }
    }
    /** Resets all morphs */
    clear() {
        this.weights([
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0, // Cheeks and jaw narrowing
        ]);
    }
}

exports.FaceMorph = FaceMorph;
