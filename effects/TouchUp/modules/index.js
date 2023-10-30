'use strict';

const createSetState = (modules) => (state) => {
    if (typeof state === "string")
        state = JSON.parse(state);
    // clear old state
    for (const module of Object.values(modules))
        if ("clear" in module)
            module.clear();
    // set new state
    for (const [name, settings] of Object.entries(state)) {
        const module = modules[name];
        if (typeof module === "undefined") {
            bnb.log(`Unable to set "${name}" parameters. The module "${name}" is not found.`);
            continue;
        }
        if (!isObject(settings)) {
            bnb.log(`Unable to set "${name}" parameters. The parameters "${name}" is not an object.`);
            continue;
        }
        for (const [property, value] of Object.entries(settings)) {
            const method = module[property];
            if (typeof method !== "function") {
                bnb.log(`Unable to call "${name}.${property}()". The "${name}.${property}" is not a function.`);
                continue;
            }
            if (Array.isArray(value))
                method.apply(module, value);
            else
                method.call(module, value);
        }
    }
};
function isObject(obj) {
    return obj instanceof Object && obj !== null;
}

exports.createSetState = createSetState;
