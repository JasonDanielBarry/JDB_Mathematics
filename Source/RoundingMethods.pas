unit RoundingMethods;

interface

    uses
        system.Math
        ;

    function roundToBaseMultiple(const valueIn, roundingBaseIn : double; const roundingModeIn : TRoundingMode = TRoundingMode.rmNearest) : double;

implementation

    function roundDownToBaseMultiple(const valueIn, roundingBaseIn : double) : double;
        begin
            result := roundingBaseIn * Floor( valueIn / roundingBaseIn );
        end;

    function roundToNearestBaseMultiple(const valueIn, roundingBaseIn : double) : double;
        begin
            result := roundingBaseIn * Round( valueIn / roundingBaseIn );
        end;

    function roundUpToBaseMultiple(const valueIn, roundingBaseIn : double) : double;
        begin
            result := roundingBaseIn * Ceil( valueIn / roundingBaseIn );
        end;

    function roundToBaseMultiple(const valueIn, roundingBaseIn : double; const roundingModeIn : TRoundingMode = TRoundingMode.rmNearest) : double;
        var
            abs_value,
            roundedValue    : double;
            valueSign       : TValueSign;
        begin
            valueSign := Sign( valueIn );
            abs_value := abs( valueIn );

            roundedValue := 0;

            case ( roundingModeIn ) of
                TRoundingMode.rmDown, TRoundingMode.rmTruncate:
                    roundedValue := roundDownToBaseMultiple( abs_value, roundingBaseIn );

                TRoundingMode.rmNearest:
                    roundedValue := roundToNearestBaseMultiple( abs_value, roundingBaseIn );

                TRoundingMode.rmUp:
                    roundedValue := roundUpToBaseMultiple( abs_value, roundingBaseIn );
            end;

            result := valueSign * roundedValue;
        end;

end.
