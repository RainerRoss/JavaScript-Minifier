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
