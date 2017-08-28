component implements="Renderer" mixin="controller" {
    public function init() {
        this.format = "json";
        return this;
    }

    public any function render(required any data, required any instance, struct context={}) {
        setting showdebugoutput = false;
        var loc = {};
        loc.indent = getIndent(arguments.context);
        loc.json = SerializeJSON(arguments.data);
        loc.output = formatJson(loc.json.toCharArray(), loc.indent);
        cfcontent( type = "text/json;charset=utf-8");
        arguments.instance.response = loc.output;
    }

    private numeric function getIndent(struct context) {
        var indent = 0;
        var indentFromHttpAccept = getIndentFromHttpAccept();
        if (indentFromHttpAccept > 0) {
            indent = indentFromHttpAccept;
        } else if (arguments.context.keyExists("indent") && isNumeric(arguments.context.indent)) {
            indent = arguments.context.indent;
        }
        return indent;
    }

    private string function formatJson(required array jsonString, indent = 4) {
        var json = arguments.jsonString.duplicate();
        var newLine = createObject("java", "java.lang.System").getProperty("line.separator");
        var output = createObject("java", "java.lang.StringBuilder");
        var depth = 0;
        var insideQuote = false;
        for (var i = 1; i <= arrayLen(json); i++) {
            if ((json[i] == '}' || json[i] == ']') && !insideQuote) {
                depth--;
                output.append(appendNewLineWithIndent(depth, indent));
            }
            output.append(json[i]);
            if (((json[i] == '{' || json[i] == '[') || (json[i] == ',')) && !insideQuote) {
                if (json[i] != ',') depth++;
                output.append(appendNewLineWithIndent(depth, indent));
            }
            if (json[i] == ':') {
                output.append(" ");
            }
            if (json[i] == '"') {
                insideQuote = !insideQuote;
            }
        }
        return output.toString();
    }

    private string function appendNewLineWithIndent(required numeric depth, required numeric indent) {
        var output = createObject("java", "java.lang.StringBuilder");
        var newLine = createObject("java", "java.lang.System").getProperty("line.separator");
        return output.append(newLine).append(repeatString(" ", arguments.depth*arguments.indent));
    }

    private numeric function getIndentFromHttpAccept() {
        var loc = {};
        loc.indent = 0;
        loc.plist = lCase(cgi.HTTP_ACCEPT);
        loc.plist.listEach(function(element, index) {
            element = reReplace(element, "[[:space:]]","","ALL");
            if (find("indent=", element)) {
                var pos = find("=", element);
                var length = len(element);
                var indentAmount = mid(element, pos + 1, length-pos);
                if (isNumeric(indentAmount)) {
                    loc.indent = indentAmount;
                }
            }
        }, ";");
        return loc.indent;
    }
}
