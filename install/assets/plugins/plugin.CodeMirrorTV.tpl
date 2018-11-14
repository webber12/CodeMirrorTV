//<?php
/**
 * CodeMirrorTV
 *
 * plugin for usage CodeMirror in TV textarea
 *
 * @author      webber (web-ber12@yandex.ru)
 * @category    plugin
 * @version     0.1
 * @license     http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnDocFormRender
 * @internal    @properties &tvs=TV IDs List;string;
 * @internal    @installset base, sample
 * @internal    @modx_category Manager and Admin
 */
 
$e = &$modx->Event;
if ($e->name == 'OnDocFormRender') {
    global $tvsArray;
    $output = '';
    $path = MODX_SITE_URL;
    $exists_tvs = array_intersect(array_map('trim', explode(',', $tvs)), array_column($tvsArray, 'id'));
    if (!empty($exists_tvs)) {
        $q = $modx->db->getValue("SELECT properties FROM " . $modx->getFullTableName("site_plugins") . " WHERE `name`='CodeMirror' LIMIT 0,1");
        $prop = $modx->parseProperties($q);
        $def_config_fields = array('theme', 'darktheme', 'indentUnit', 'tabSize', 'matchBrackets', 'lineWrapping', 'indentWithTabs', 'undoDepth', 'historyEventDelay');
        $config = array();
        foreach ($prop as $k => $v) {
            if (in_array($k, $def_config_fields)) {
                $config[$k] = $v;
            }
        }
        $def_config = json_encode(json_decode(json_encode($config)));
        $fontSize = $prop['fontSize'];
        $lineHeight = $prop['lineHeight'];
        $theme = $prop['theme'];
        $darktheme = $prop['darktheme'];
        $output .= <<<OUT
        
        <link rel="stylesheet" href="{$path}assets/plugins/codemirror/cm/lib/codemirror.css">
        <link rel="stylesheet" href="{$path}assets/plugins/codemirror/cm/addon.css">
        <link rel="stylesheet" href="{$path}assets/plugins/codemirror/cm/theme/{$theme}.css">
        <link rel="stylesheet" href="{$path}assets/plugins/codemirror/cm/theme/{$darktheme}.css">
        <style>.CodeMirror { font-size:{$fontSize}px !important; line-height:{$lineHeight} !important; } .CodeMirror pre { font-size:{$fontSize}px !important; line-height:{$lineHeight} !important; }</style>
        <script src="{$path}assets/plugins/codemirror/cm/lib/codemirror-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/xml-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/javascript-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/css-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/clike-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/php-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/sql-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/mode/htmlmixed-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/emmet-compressed.js"></script>
        <script src="{$path}assets/plugins/codemirror/cm/addon-compressed.js"></script>


        <script type="text/javascript">
        // Add mode MODX for syntax highlighting. Dfsed on htmlmixed
        CodeMirror.defineMode("MODx-htmlmixed", function(config, parserConfig) {
            var mustacheOverlay = {
                token: function(stream, state) {
                    var ch;
                    if (stream.match("[[") || stream.match("`[[")) {
                        while ((ch = stream.next()) != null)
                            if (ch == "?" || (ch == "]" && stream.next() == "]")) break;
                        return "modxSnippet";
                    }
                    if (stream.match("{{") || stream.match("`{{")) {
                        while ((ch = stream.next()) != null)
                            if (ch == "?" || (ch == "}" && stream.next() == "}")) break;
                        stream.eat("}");
                        return "modxChunk";
                    }
                    if (stream.match("[*") || stream.match("`[*")) {
                        while ((ch = stream.next()) != null)
                            if (ch == ':' || (ch == "*" && stream.next() == "]")) break;
                        stream.eat("]");
                        return "modxTv";
                    }
                    if (stream.match("[+") || stream.match("`[+")) {
                        while ((ch = stream.next()) != null)
                            if (ch == "+" && stream.next() == "]") break;
                        stream.eat("]");
                        return "modxPlaceholder";
                    }
                    if (stream.match("[!") || stream.match("`[!")) {
                        while ((ch = stream.next()) != null)
                            if (ch == "?" || (ch == "!" && stream.next() == "]")) break;
                        return "modxSnippetNoCache";
                    }
                    if (stream.match("[(") || stream.match("`[(")) {
                        while ((ch = stream.next()) != null)
                            if (ch == ")" && stream.next() == "]") break;
                        stream.eat("]");
                        return "modxVariable";
                    }
                    if (stream.match("[~") || stream.match("`[~")) {
                        while ((ch = stream.next()) != null)
                            if (ch == "~" && stream.next() == "]") break;
                        stream.eat("]");
                        return "modxUrl";
                    }
                    if (stream.match("[^") || stream.match("`[^")) {
                        while ((ch = stream.next()) != null)
                            if (ch == "^" && stream.next() == "]") break;
                        stream.eat("]");
                        return "modxConfig";
                    }
                    if (ch = stream.match(/&([^\s=]+=)?/)) {
                        if(ch[1] != undefined)
                            return "modxAttribute";
                    }
                    if (stream.match(/`([^\s=]+`)?/)) {
                        if (stream.match("`[")) return;
                        return "modxAttributeValue";
                    }
                    if (stream.match("@inherit", true, true) ||
                        stream.match("@select", true, true) ||
                        stream.match("@eval", true, true) ||
                        stream.match("@directory", true, true) ||
                        stream.match("@chunk", true, true) ||
                        stream.match("@document", true, true) ||
                        stream.match("@file", true, true) ||
                        stream.match("@code", true, true)
                    ) {
                        return "modxBinding";                   
                    }
                    if (stream.match("!]")) {
                        return "modxSnippetNoCache";
                    }
                    if (stream.match("]]")) {
                        return "modxSnippet";
                    }
                    if (stream.match("}}")) {
                        return "modxChunk";
                    }
                    if (stream.match("*]")) {
                        return "modxTv";
                    }
                    while (stream.next() != null && !stream.match("[[", false) && !stream.match("&", false) && !stream.match("{{", false) && !stream.match("[*", false) && !stream.match("[+", false) && !stream.match("[!", false) && !stream.match("[(", false) && !stream.match("[~", false) && !stream.match("[^", false) && !stream.match("`", false) && !stream.match("!]", false) && !stream.match("]]", false) && !stream.match("*]", false)) {}
                    return null;
                }
            };
            return CodeMirror.overlayMode(CodeMirror.getMode(config, parserConfig.backdrop || "htmlmixed"), mustacheOverlay);
        });
        function makeMarker(symbol) {
          var marker = document.createElement("div");
          marker.style.color = "#822";
          marker.className = "cm-marker";
          marker.innerHTML = "*";
          return marker;
        }
        //Basic settings
        var config = extend({
            mode: 'MODx-htmlmixed',
            defaulttheme: 'default',
            readOnly: false,
            lineNumbers: true,
            gutters: ["CodeMirror-linenumbers", "breakpoints"],
            styleActiveLine: false,
            extraKeys:{
                // add marker
                "Ctrl-Space": function(cm){
                    var n = cm.getCursor().line;
                    var info = cm.lineInfo(n);
                    foldFunc(cm, n);
                    cm.setGutterMarker(n, "breakpoints", info.gutterMarkers ? null : makeMarker("+"));
                },
                // save
                "Ctrl-S": function(cm) {
                    var el = document.querySelector('a#Button1') || document.querySelector('#Button1 > a');
                    if(el) el.onclick();
                },
                // save and continue
                "Ctrl-E": function(cm) {
                    var el = document.querySelector('a#Button1') || document.querySelector('#Button1 > a');
                    var el2 = document.querySelector('#stay');
                    if(el && el2) {
                        el2.options[1].selected = true;
                        el.onclick();
                    }
                },
                // save and new
                "Ctrl-B": function(cm) {
                    var el = document.querySelector('a#Button1') || document.querySelector('#Button1 > a');
                    var el2 = document.querySelector('#stay');
                    if(el && el2) {
                        el2.options[0].selected = true;
                        el.onclick();
                    }
                },
                // save and quit
                "Ctrl-Q": function(cm) {
                    var el = document.querySelector('a#Button1') || document.querySelector('#Button1 > a');
                    var el2 = document.querySelector('#stay');
                    if(el && el2) {
                        el2.options[2].selected = true;
                        el.onclick();
                    }
                }
            }
        }, {$def_config});
        </script>
OUT;
        foreach ($exists_tvs as $tv) {
            $output .= '<script>var myCodeMirror_tv' . $tv . ' = CodeMirror.fromTextArea(document.getElementById("tv' . $tv . '"), config);</script>';
        }
    }
    $e->output($output);
}