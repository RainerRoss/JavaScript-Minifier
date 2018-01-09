         ctl-opt main(main) dftactgrp(*no) alloc(*teraspace);
      //------------------------------------------------------------------//
      //                                                                  //
      // JavaScript Minifier                                              //
      //                                                                  //
      //-----------------                                                 //
      // R.Ross 01.2018 *                                                 //
      //------------------------------------------------------------------//
      // Array File-Data                                                  //
      //------------------------------------------------------------------//

         dcl-ds  DsFile      qualified inz;
                  SrcData    sqltype(CLOB:1000000) ccsid(*utf8);
                  EncData    sqltype(CLOB:1000000);   // Encoded Data
                  MinData    sqltype(CLOB:1000000);   // Minified Data
         end-ds;

      //------------------------------------------------------------------//
      // Array Input-Data from Google                                     //
      //------------------------------------------------------------------//

         dcl-ds  DsData      qualified inz;
                  MinCode    sqltype(CLOB:1000000) ccsid(*utf8);
                  SrcSize    int(10);
                  CmpSize    int(10);
         end-ds;

      //------------------------------------------------------------------//
      // Main                                                             //
      //------------------------------------------------------------------//
         dcl-proc main;

         dcl-s   LocStmf     varchar(100);

           exec sql set option datfmt=*iso, timfmt=*iso, commit=*chg,
                               closqlcsr=*endactgrp;

           LocStmf = '/tmp/js/test.js';

           exec sql set :DsFile.SrcData = get_clob_from_file(:LocStmf);

           if sqlcode >= *zero and DsFile.SrcData_len > *zero;
              encodeBase64(DsFile);
              minifyData(DsFile);
              parseResult(DsFile);
           endif;

         end-proc;
      //------------------------------------------------------------------//
      // Encode POST-Data to Base64                                       //
      //------------------------------------------------------------------//
         dcl-proc encodeBase64;
         dcl-pi *n;
                 PiFile      likeds(DsFile);
         end-pi;

         dcl-s   LocData     varchar(1000);                // data to encode
         dcl-s   LocSize     uns(10) inz(%len(LocData));   // encode size
         dcl-s   LocEnc      varchar(30000);               // encoded data
         dcl-s   LocEncSize  uns(10);                      // encoded size
         dcl-s   LocStart    uns(10);                      // start position
         dcl-s   LocRest     uns(10);                      // rest bytes
         dcl-s   LocInd      uns(10);                      // index

           LocRest = PiFile.SrcData_len;

           dou LocEncSize >= PiFile.SrcData_len;
             LocInd += 1;

             LocStart = (LocSize * (LocInd - 1)) + 1;

             if LocRest >= LocSize;
                LocRest -= LocSize;
                LocData  = %subst(PiFile.SrcData_data:LocStart:LocSize);
                exec sql set :LocEnc = systools.urlencode(:LocData,'UTF-8');
                exec sql set :PiFile.EncData = :PiFile.EncData concat :LocEnc;
                LocEncSize += LocSize;
              else;
                LocData  = %subst(PiFile.SrcData_data:LocStart:LocRest);
                exec sql set :LocEnc = systools.urlencode(:LocData,'UTF-8');
                exec sql set :PiFile.EncData = :PiFile.EncData concat :LocEnc;
                LocEncSize += LocRest;
             endif;

           enddo;

         end-proc;
      //------------------------------------------------------------------//
      // Minify data with Google Closure Compiler                         //
      //------------------------------------------------------------------//
         dcl-proc minifyData;
         dcl-pi *n;
                 PiFile      likeds(DsFile);
         end-pi;

         dcl-s   LocData     sqltype(CLOB:1000000);   // CLOB 1 MB

         dcl-s   LocURL      varchar(256);
         dcl-s   LocHeader   varchar(256);
         dcl-s   LocOptions  varchar(256);

           LocURL    = 'https://closure-compiler.appspot.com/compile';

           LocHeader =
             '<httpHeader connectTimeout="2000" readTimeout="20000">' +
              '<header name="Content-Type" ' +
                      'value="application/x-www-form-urlencoded"/>'  +
              '</httpHeader>';

           LocOptions =
             'compilation_level=WHITESPACE_ONLY&' +
             'output_format=json&'                +
             'output_info=statistics&'            +
             'output_info=warnings&'              +
             'output_info=errors&'                +
             'output_info=compiled_code&'         +
             'js_code=';

           exec sql set :LocData = :LocOptions concat :PiFile.EncData;

           exec sql
            values systools.httppostclob
                  (:LocURL, :LocHeader, :LocData)
              into :PiFile.MinData;

           sqlcode = sqlcode;

         end-proc;
      //------------------------------------------------------------------//
      // Parse result data from Google and write result to IFS            //
      //------------------------------------------------------------------//
         dcl-proc parseResult;
         dcl-pi *n;
                 PiFile      likeds(DsFile);
         end-pi;

         dcl-s   LocClobFile sqltype(CLOB_FILE);      // Clob-File

           exec sql
            select x.*
             into :DsData
             from json_table (:PiFile.MinData, '$'
              columns(
               MinCode clob(1M) path '$.compiledCode',
               SrcSize int      path '$.statistics.originalSize',
               CmpSize int      path '$.statistics.compressedSize'
              )
             ) as x;

           sqlcode = sqlcode;

           if sqlcode >= *zero;
              LocClobFile_fo   = SQFOVR;
              LocClobFile_name = '/tmp/js/test_min.js';
              LocClobFile_nl   = %len(%trim(LocClobFile_name));

              exec sql set :LocClobfile = :DsData.RplCode; // write to IFS
           endif;

           sqlcode = sqlcode;

         end-proc;
      //------------------------------------------------------------------// 
