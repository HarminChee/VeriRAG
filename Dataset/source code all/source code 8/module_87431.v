`timescale 1ns / 1ps
`timescale 1ns / 1ps
module TimeCounter
#
(
    parameter TimerWidth            = 32        ,
    parameter DefaultPeriod         = 100000000
)
(
    iClock          ,
    iReset          ,
    iEnabled        ,
    iPeriodSetting  ,
    iSettingValid   ,
    iProbe          ,
    oCountValue
);
    input                       iClock          ;                                                                              
    input                       iReset          ;                                                                              
    input                       iEnabled        ;                                                                              
    input   [TimerWidth - 1:0]  iPeriodSetting  ;                                                      
    input                       iSettingValid   ;                          
    input                       iProbe          ;        
    output  [TimerWidth - 1:0]  oCountValue     ;
    reg     [TimerWidth - 1:0]  rPeriod         ;
    reg     [TimerWidth - 1:0]  rSampledCount   ;
    reg     [TimerWidth - 1:0]  rCounter        ;
    reg     [TimerWidth - 1:0]  rTimeCount      ;
    always @ (posedge iClock)
        if (iReset | !iEnabled | rTimeCount == rPeriod)
            rCounter <= {(TimerWidth){1'b0}};
        else
            if (iEnabled & iProbe)
                rCounter <= rCounter + 1'b1;
    always @ (posedge iClock)
        if (iReset | !iEnabled | rTimeCount == rPeriod)
            rTimeCount <= {(TimerWidth){1'b0}};
        else
            if (iEnabled)
                rTimeCount <= rTimeCount + 1'b1;
    always @ (posedge iClock)
        if (iReset)
            rSampledCount <= {(TimerWidth){1'b0}};
        else
            if (rTimeCount == rPeriod)
                rSampledCount <= rCounter;
    always @ (posedge iClock)
        if (iReset)
            rPeriod <= DefaultPeriod;
        else
            if (iSettingValid)
                rPeriod <= iPeriodSetting;
    assign oCountValue = rSampledCount;
endmodule
