# Plugin: CustomRenderer

## Purpose

The purpose of the Custom Renderer plugin is to provide the developer great granularity when rendering objects and queries to the front end user.  This plugin also supports custom renderers developed by the end user.

## Setup

Copy CustomRenderer-1.0.0.zip file to your plugins folder and reload your application.

## User Defined Renderers

You can create and add your own user defined renderers.  To do this, you must add a Renderer to your local cfwheels application and add the
new renderer to your **config/settings.cfm**

```
set(CustomRenderers = {
    "yaml" = "lib.myYAMLRenderer"
});
```

Within a local folder on your server, lib for example, you can add a new renderer component for your purposes.

**lib/myYAMLRenderer.cfc**
```java
component implements="Renderer" mixin="controller" {
    public function init() {
        this.format = "yaml";
        return this;
    }

    public any function render(required any data, required any instance, struct context={}) {
        setting showdebugoutput = false;
        var loc = {};
        loc.yaml = ...;
        cfcontent( type = "text/yaml;charset=utf-8");
        arguments.instance.response = loc.yaml;
    }
}
```

## Usage

Within your controller, you would specify the provides to include the possible CustomRenderers you would want to list.  If the requested format is not found in the custom renderers, the view will fall back to the renderWith();

```java
public void function init() {
    super.init();
    provides("html,json,yaml");
}

public void function countries() {
    param params.format = "html";
    countries = model("country").findAll();
    customerRenderer(data = countries, context = {"indent":4});
}
```
