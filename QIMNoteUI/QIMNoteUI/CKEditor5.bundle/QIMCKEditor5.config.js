var ckeditorConfig = {
    "theme" : "Lark",
    "skin": "kama",
    "highlight": {
        "options": [
            {
                "model": "yellowMarker", 
                "class": "marker-yellow", 
                "title": "Yellow Marker", 
                "color": "var(--ck-highlight-marker-yellow)", 
                "type": "marker"
            }, 
            {
                "model": "greenMarker", 
                "class": "marker-green", 
                "title": "Green marker", 
                "color": "var(--ck-highlight-marker-green)", 
                "type": "marker"
            }, 
            {
                "model": "pinkMarker", 
                "class": "marker-pink", 
                "title": "Pink marker", 
                "color": "var(--ck-highlight-marker-pink)", 
                "type": "marker"
            }, 
            {
                "model": "blueMarker", 
                "class": "marker-blue", 
                "title": "Blue marker", 
                "color": "var(--ck-highlight-marker-blue)", 
                "type": "marker"
            }, 
            {
                "model": "redPen", 
                "class": "pen-red", 
                "title": "Red pen", 
                "color": "var(--ck-highlight-pen-red)", 
                "type": "pen"
            }, 
            {
                "model": "greenPen", 
                "class": "pen-green", 
                "title": "Green pen", 
                "color": "var(--ck-highlight-pen-green)", 
                "type": "pen"
            }
        ]
    }, 
    "alignment": {
        "options": [
            "left", 
            "right"
        ]
    }, 
    "table": {
        "toolbar": [
            "tableColumn", 
            "tableRow", 
            "mergeTableCells"
        ]
    }, 
    "toolbar": [
        "heading", 
        "|", 
        "bold", 
        "italic", 
        "underline", 
        "strikethrough", 
        "|", 
        "bulletedList", 
        "numberedList", 
        "|", 
        "alignment", 
        "|", 
        "highlight", 
        "code", 
        "blockQuote", 
        "|", 
        "link", 
        "imageUpload", 
        "insertTable", 
        "|", 
        "undo", 
        "redo"
    ]
};
