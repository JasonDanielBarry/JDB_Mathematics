unit LinearInterpolationMethods;

interface

    uses
        system.SysUtils, system.Math;

    function lerp(const t_In, startValueIn, endValueIn : double) : double; inline;

    function linearInterpolate(X, X0, Y0, X1, Y1 : double) : double; inline;

implementation

    function lerp(const t_In, startValueIn, endValueIn : double) : double;
        begin
            result := startValueIn + (endValueIn - startValueIn) * t_In;
        end;

    function linearInterpolate(X, X0, Y0, X1, Y1 : double) : double;
        var
            t : double;
        begin
            t := (X - X0) / (X1 - X0);

            result := lerp(t, Y0, Y1);
        end;

end.
