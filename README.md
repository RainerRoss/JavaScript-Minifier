# JavaScript-Minifier

Go [here](https://closure-compiler.appspot.com/home) to test the Google Closure Compiler.

### Example Request with `console.log(  "Hello World"   );` and HTTPPOSTCLOB using Google Closure Compiler 
```
values SYSTOOLS.HTTPPOSTCLOB (
 'https://closure-compiler.appspot.com/compile',
 '<httpHeader>
    <header name="Content-Type" value="application/x-www-form-urlencoded"/>
  </httpHeader>',
 'compilation_level=WHITESPACE_ONLY&' concat 
 'output_format=json&' concat 
 'output_info=statistics&' concat 
 'output_info=warnings&' concat 
 'output_info=errors&' concat 
 'output_info=compiled_code&' concat 
 'js_code=' concat systools.urlencode('console.log(   "Hello World"   );','UTF-8')
);
```
### Request Result 
```
{
    "compiledCode": "console.log(\"Hello World\");",
    "statistics": {
        "originalSize": 46,
        "originalGzipSize": 60,
        "compressedSize": 27,
        "compressedGzipSize": 47,
        "compileTime": 0
    }
}

```
## The RPG-program [JSMinify](https://github.com/RainerRoss/JavaScript-Minifier/blob/master/JSMINIFY.SQLRPGLE) works with the following steps
### 1) Load the file [test.js](https://github.com/RainerRoss/JavaScript-Minifier/blob/master/test.js) from directory `/tmp/js` with `get_clob_from_file()`
### 2) URL-encode the JavaScript code with `urlencode()`
### 3) Request to the Google Closure Compiler with `httppostclob()`
### 4) Parse the result with `json_table()`
### 5) Write the result to IFS-file [test_min.js](https://github.com/RainerRoss/JavaScript-Minifier/blob/master/test_min.js) 
