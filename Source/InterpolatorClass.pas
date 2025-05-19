unit InterpolatorClass;

interface

    uses
        system.SysUtils, system.Math, system.Types,
        LinearInterpolationMethods;

    type
        TInterpolator = class
            strict private
                x0, y0,
                x1, y1  : double;
            public
                constructor create(); overload;
                constructor create(const x0In, x1In, y0In, y1In : double); overload;
                destructor destroy(); override;
                procedure setPoints(const x0In, x1In, y0In, y1In : double); overload;
                procedure setPoints(const point0In, point1In : TPointF); overload;
                function interpolateX(const xIn : double) : double;
                function interpolateY(const yIn : double) : double;
                function interpolate(const tIn : double) : TPointF;
                function calculateLineLength() : double;
        end;

implementation

    //private

    //public
        constructor TInterpolator.create();
            begin
                inherited create();
            end;

        constructor TInterpolator.create(const x0In, x1In, y0In, y1In : double);
            begin
                inherited create();

                setPoints(x0In, x1In, y0In, y1In);
            end;

        destructor TInterpolator.Destroy();
            begin
                inherited Destroy();
            end;

        procedure TInterpolator.setPoints(const x0In, x1In, y0In, y1In : double);
            begin
                x0 := x0In;
                x1 := x1In;
                y0 := y0In;
                y1 := y1In;
            end;

        procedure TInterpolator.setPoints(const point0In, point1In : TPointF);
            begin
                setPoints( point0In.X, point1In.x, point0In.y, point1In.y );
            end;

        function TInterpolator.interpolateX(const xIn : double): double;
            begin
                result := linearInterpolate( xIn, x0, y0, x1, y1 );
            end;

        function TInterpolator.interpolateY(const yIn : double) : double;
            begin
                result := linearInterpolate( yIn, y0, x0, y1, x1 );
            end;

        function TInterpolator.interpolate(const tIn : double) : TPointF;
            var
                pointOut : TPointF;
            begin
                pointOut.X := lerp( tIn, x0, x1 );
                pointOut.Y := lerp( tIn, y0, y1 );

                result := pointOut;
            end;

        function TInterpolator.calculateLineLength() : double;
            var
                dx, dy : double;
            begin
                dx := x1 - x0;
                dy := y1 - y0;

                result := Norm( [dx, dy] );
            end;

end.
