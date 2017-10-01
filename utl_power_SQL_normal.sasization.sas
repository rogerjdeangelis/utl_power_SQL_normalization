Power_of_SQL_with_normalized_data;


     Not sure I completlely understood the problem. Some extra variables in the data?
     see end of message for more detail.

     WORKING CODE
     =============
       SAS

         data nrm(where=(dteval ne .));
          set have;
          dtevar='PXDT1 ';dteval=PXDT1;prcvar='D_PX1';prcval=D_PX1;  output;
          dtevar='PXDT2 ';dteval=PXDT2;prcvar= 'D_PX2';prcval=D_PX2; output;
          dtevar='N_PDT1';dteval=N_PDT1;prcvar='N_PX1';prcval=N_PX1; output;
          dtevar='N_PDT2';dteval=N_PDT2;prcvar='N_PX2';prcval=N_PX2; output;
          keep regn dte: prc:;

         proc sort data=nrm out=havdup nouniquekey;
         by dteval prcval;

       WPS (does not support nouniquekey yet)

          proc sort data=nrm out=want nouniquekey;
                                      ^
          ERROR: Option "nouniquekey" is not known for the PROC SORT statement

       SOAPBOX ON
          Wish WPS would concentrate on Base SAS and not IML.
       SOAPBOX OFF

see
https://goo.gl/fiD2AY
https://communities.sas.com/t5/Base-SAS-Programming/Comparing-Arrays-in-same-dataset/m-p/400154


HAVE
====

    Up to 40 obs WORK.TEST_GR total obs=5

    Obs    REGN     D_PX1    D_PX2    PXDT1    PXDT2    N_PX1    N_PX2    N_PDT1    N_PDT2

     1     001      3AN20    1GV52    19082    19082    3GY20    1GV52     19081     19081
     2     002      1VC74    3AN20    19112    19112    3AN20              19112         .
     3     003      3OT20             19142        .    3OT20    3AN20     19141     19141
     4     004      3GY20    1GV52    19173    19173    3GY20    1GV52     19173     19173
     5     005      3OT20    3AN20    19178    19178    3OT20    3AN20     19178     19178


WANT
====

   WORK.WANT total obs=10

    Obs    REGN    DTEVAR    DTEVAL    PRCVAR    PRCVAL

      1    002     PXDT2      19112    D_PX2     3AN20   * repeat procedure on the same day
      2    002     N_PDT1     19112    N_PX1     3AN20

      3    004     PXDT2      19173    D_PX2     1GV52
      4    004     N_PDT2     19173    N_PX2     1GV52
      5    004     PXDT1      19173    D_PX1     3GY20
      6    004     N_PDT1     19173    N_PX1     3GY20

      7    005     PXDT2      19178    D_PX2     3AN20
      8    005     N_PDT2     19178    N_PX2     3AN20
      9    005     PXDT1      19178    D_PX1     3OT20
     10    005     N_PDT1     19178    N_PX1     3OT20

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;
data have ;
input @1 chart $5.
        @6 regn  $3.
        @9 AdmDate yymmdd8.
      @17 DisDate yymmdd8.
        @25 D_Px1 $5.
        @30 D_Px2 $5.
        @35 PxDt1 yymmdd8.
        @43 PxDt2 yymmdd8.
        @51 N_Px1 $5.
        @56 N_Px2 $5.
        @61 N_PDt1 yymmdd8.
        @69 N_PDt2 yymmdd8.
;
format admdate disdate PxDt1-PxDt2 N_PDt1-N_PDt2 yymmdd8.;
cards4;
A123400120120329201204023AN201GV5220120330201203303GY201GV522012032920120329
A586700220120429201205051VC743AN2020120429201204293AN20     20120429
A898900320120529201205313OT20     20120529        3OT203AN202012052820120528
A232400420120629201207153GY201GV5220120629201206293GY201GV522012062920120629
A285500520120704201207143OT203AN2020120704201207043OT203AN202012070420120704
;;;;
run;quit;


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;
data nrm(where=(dteval ne .));
 set have;
 dtevar="PXDT1 ";dteval=PXDT1;prcvar="D_PX1";prcval=D_PX1;  output;
 dtevar="PXDT2 ";dteval=PXDT2;prcvar= "D_PX2";prcval=D_PX2; output;
 dtevar="N_PDT1";dteval=N_PDT1;prcvar="N_PX1";prcval=N_PX1; output;
 dtevar="N_PDT2";dteval=N_PDT2;prcvar="N_PX2";prcval=N_PX2; output;
 keep regn dte: prc:;
run;quit;

proc sort data=nrm out=want nouniquekey;
by dteval prcval;
run;quit;

*    _
  __| | ___   ___
 / _` |/ _ \ / __|
| (_| | (_) | (__
 \__,_|\___/ \___|

;

"My objective is to take the inpatient data set, link it to the ED dataset
(for those admitted via the Emergency Department) and determine
if the same procedure with the same procedure date is coded in both datasets.

My original step was to combine the two datasets via proc SQL where the
ED dispoistion date = inpatient admit date and that is working fine (though
I welcome any feedback on whether this is the correct approach).  So now I
have a dataset per chart number with 20 possible procedures (pxcde1-pxcde20)
and 10 potential ED procedures (px1-px10).  I also have 20 possible inpatient proced
ure dates pxstdate1-pxstdate20) and 10 possible ED procedure dates (pxdt1-pxdt10).

What I want to do is compare the inpatient procedure with procedure date to
the ED procedures and procedure dates to see if they match.  Below is some
test data where registration 002, 004 and 005 should be matched and the
other two are not.  I appreciate any and all assistance, thanks.."



