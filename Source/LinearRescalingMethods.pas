unit LinearRescalingMethods;

interface

    uses
        System.SysUtils, system.Math;

    //scale line
        procedure scaleLinear(  const   startValueIn, endValueIn,
                                        scaleFactorIn           : double;
                                out     newEndValueOut          : double ); overload;

        procedure scaleLinear(  const   startValueIn,       endValueIn,
                                        scaleAboutValueIn,  scaleFactorIn   : double;
                                out     newStartValueOut,   newEndValueOut  : double ); overload;

        procedure resizeLine(   const   startValueIn, endValueIn,
                                        newLengthIn             : double;
                                out     newEndValueOut          : double    ); overload;

        procedure resizeLine(   const   startValueIn,       endValueIn,
                                        scaleAboutValueIn,  newLengthIn     : double;
                                out     newStartValueOut,   newEndValueOut  : double    ); overload;

implementation

    //scale line
        procedure scaleLinear(  const   startValueIn, endValueIn,
                                        scaleFactorIn           : double;
                                out     newEndValueOut          : double );
            var
                lengthChange, lengthOld : double;
            begin
                //check if the start value and end value are identical - cannot divide by zero
                    if ( SameValue( startValueIn, endValueIn ) ) then
                        begin
                            newEndValueOut := endValueIn;

                            exit();
                        end;

                //calculate old length
                    lengthOld := endValueIn - startValueIn;

                //calculate change in length
                    lengthChange := (scaleFactorIn - 1) * lengthOld;

                //calculate new end value
                    newEndValueOut := endValueIn + lengthChange;
            end;

        procedure scaleLinear(  const   startValueIn,       endValueIn,
                                        scaleAboutValueIn,  scaleFactorIn   : double;
                                out     newStartValueOut,   newEndValueOut  : double );
            begin
                //scale from start value to scale-about-value
                    scaleLinear( scaleAboutValueIn, startValueIn, scaleFactorIn, newStartValueOut );

                //scale from scale-about-value to end value
                    scaleLinear( scaleAboutValueIn, endValueIn, scaleFactorIn, newEndValueOut );
            end;

        function calculateScaleFactor(const oldLineStartValueIn, oldLineEndValueIn, newLineLengthIn : double) : double;
            begin
                result := abs( newLineLengthIn / (oldLineEndValueIn - oldLineStartValueIn) );
            end;

        procedure resizeLine(   const   startValueIn, endValueIn,
                                        newLengthIn             : double;
                                out     newEndValueOut          : double    );
            var
                scaleFactor : double;
            begin
                if ( SameValue( startValueIn, endValueIn ) ) then
                    begin
                        newEndValueOut := startValueIn + newLengthIn;
                        exit();
                    end;

                //the scale factor is the ratio of the new line length to the old line length
                    scaleFactor := calculateScaleFactor( startValueIn, endValueIn, newLengthIn );

                scaleLinear(startValueIn, endValueIn,
                            scaleFactor,
                            newEndValueOut          );
            end;

        procedure resizeLine(   const   startValueIn,       endValueIn,
                                        scaleAboutValueIn,  newLengthIn     : double;
                                out     newStartValueOut,   newEndValueOut  : double    );
            var
                scaleFactor : double;
            begin
                if ( SameValue( startValueIn, endValueIn ) ) then
                    begin
                        newStartValueOut    := startValueIn - (newLengthIn / 2);
                        newEndValueOut      := endValueIn   + (newLengthIn / 2);
                        exit();
                    end;

                //the scale factor is the ratio of the new line length to the old line length
                    scaleFactor := calculateScaleFactor( startValueIn, endValueIn, newLengthIn );

                scaleLinear(startValueIn,       endValueIn,
                            scaleAboutValueIn,  scaleFactor,
                            newStartValueOut,   newEndValueOut);
            end;

end.
