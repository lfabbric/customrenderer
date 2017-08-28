component hint="cfWheels linkTo Overload Plugin" output="false" mixin="controller" {

    public function init() {
        this.version = "1.3.4,1.4,1.4.1,1.4.2,1.4.3,1.4.4,1.4.5";
        return this;
    }

    public any function customerRenderer(required any data, string controller = "#variables.params.controller#", string action = "#variables.params.action#", struct context = {}) {
        var loc = {};
        $args(name="renderWith", args=arguments);

        loc.contentType = $requestContentType();
        loc.acceptableFormats = $acceptableFormats(action=arguments.action);
        try {
            var renderer = getRenderer(loc.contentType);
            renderer.render(instance = variables.$instance, argumentCollection = arguments);
        } catch (InvalidRenderer e) {
            arguments.delete(context);
            return core.renderWith(arguments);
        }
    }

    public renderers.Renderer function getRenderer(required string contentType) {
        var loc = {};
        loc.renderers = $crLoadRenderers();
        if (loc.renderers.keyExists(arguments.contentType)) {
            return createObject("component", loc.renderers[arguments.contentType]);
        }
        throw(type = "InvalidRenderer");
    }

    public struct function $crLoadRenderers() {
        var found = false;
        var loc = {};
        if (params.keyExists("reload")) {
            structDelete(application.plugins, "customrenderer");
        }
        lock name = "getSettings" timeout = "5" type = "readonly" {
            if (application.keyExists("plugins") && application.plugins.keyExists("customrenderer") && application.plugins.customrenderer.keyExists("createdat")) {
                if (application.plugins.customrenderer.keyExists("settings") && datediff("s", application.plugins.customrenderer.createdat, now()) <= 15) {
                    return application.plugins.customrenderer.settings.duplicate();
                }
            }
        }
        loc.appKey = $appKey();
        pluginPath = application[loc.appKey].webPath & application[loc.appKey].pluginPath;
        var path = pluginPath & "/customrenderer/settings.json";
        if (fileExists(expandpath(path))) {
            var settings = fileRead(expandpath(path), "utf-8");
            settings = $crMergeRendererPaths(deserializeJSON(settings).renderers);
            lock timeout = "10" scope = "application" type = "exclusive" {
                application.plugins.customrenderer = {
                    "createdat" = now(),
                    "settings" = settings
                };
            }
            return application.plugins.customrenderer.settings.duplicate();
        }
        return {};
    }

    public struct function $crMergeRendererPaths(required struct renderers) {
        var loc = {};
        if (application.wheels.keyExists("CustomRenderers") && isStruct(application.wheels.CustomRenderers)) {
            arguments.renderers.append(application.wheels.CustomRenderers, true);
        }
        return arguments.renderers;
    }
}
