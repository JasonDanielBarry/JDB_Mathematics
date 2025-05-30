unit GeometryBaseClass;

interface

    uses
        system.SysUtils, system.Math,
        GeometryTypes, GeomBox;

    type
        TGeomBase = class
            private
                //
            protected
                var
                    arrGeomPoints : TArray<TGeomPoint>;
            public
                //constructor
                    constructor create();
                //destructor
                    destructor destroy(); override;
                //bounding box
                    function boundingBox() : TGeomBox;
                    class function determineBoundingBox(arrGeomIn : TArray<TGeomBase>) : TGeomBox; static;
                //centroid point
                    function calculateCentroidPoint() : TGeomPoint; virtual;
                    procedure setCentroidPoint(const xIn, yIn : double); overload;
                    procedure setCentroidPoint(const xIn, yIn, zIn : double); overload;
                    procedure setCentroidPoint(const newCentroidPointIn : TGeomPoint); overload;
                //drawing points
                    function getArrGeomPoints() : TArray<TGeomPoint>;
                //rotation
                    procedure rotate(   const rotationAngleIn           : double;
                                        const rotationReferencePointIn  : TGeomPoint    ); overload;
                    procedure rotate(const rotationAngleIn : double); overload;
                    class procedure rotate( const rotationAngleIn           : double;
                                            const rotationReferencePointIn  : TGeomPoint;
                                            arrGeometryInOut                : TArray<TGeomBase> ); overload; static;
                //scaling
                    procedure scale(const scaleFactorIn         : double;
                                    const scaleReferencePointIn : TGeomPoint); overload;
                    procedure scale(const scaleFactorIn : double); overload;
                    class procedure scale(  const scaleFactorIn         : double;
                                            const scaleReferencePointIn : TGeomPoint;
                                            arrGeometryInOut            : TArray<TGeomBase> ); overload; static;
                //shift the geometry
                    procedure shift(const deltaXIn, deltaYIn, deltaZIn : double); overload;
                    procedure shift(const deltaXIn, deltaYIn : double); overload;
                    class procedure shift(  const deltaXIn, deltaYIn    : double;
                                            arrGeometryInOut            : TArray<TGeomBase> ); overload; static;
        end;

implementation

    //public
        //constructor
            constructor TGeomBase.create();
                begin
                    inherited create();
                end;

        //destructor
            destructor TGeomBase.destroy();
                begin
                    SetLength(arrGeomPoints, 0);

                    inherited destroy();
                end;

        //bounding box
            function TGeomBase.boundingBox() : TGeomBox;
                begin
                    result := TGeomBox.determineBoundingBox( arrGeomPoints );
                end;

            class function TGeomBase.determineBoundingBox(arrGeomIn : TArray<TGeomBase>) : TGeomBox;
                var
                    i, geomCount    : integer;
                    boxOut          : TGeomBox;
                    arrGeomBox      : TArray<TGeomBox>;
                begin
                    geomCount := length(arrGeomIn);

                    if (geomCount < 1) then
                        exit();

                    SetLength(arrGeomBox, geomCount);

                    for i := 0 to (geomCount - 1) do
                        arrGeomBox[i] := arrGeomIn[i].boundingBox();

                    boxOut := TGeomBox.determineBoundingBox( arrGeomBox );

                    result := boxOut;
                end;

        //centroid point
            function TGeomBase.calculateCentroidPoint() : TGeomPoint;
                begin
                    result := TGeomPoint.calculateCentroidPoint( arrGeomPoints );
                end;

            procedure TGeomBase.setCentroidPoint(const xIn, yIn : double);
                begin
                    setCentroidPoint( xIn, yIn, 0 );
                end;

            procedure TGeomBase.setCentroidPoint(const xIn, yIn, zIn : double);
                var
                    newCentroidPoint : TGeomPoint;
                begin
                    newCentroidPoint := TGeomPoint.create( xIn, yIn, zIn );

                    setCentroidPoint( newCentroidPoint );
                end;

            procedure TGeomBase.setCentroidPoint(const newCentroidPointIn : TGeomPoint);
                begin
                    TGeomPoint.shiftArrPointsByVector( calculateCentroidPoint(), newCentroidPointIn, arrGeomPoints );
                end;

        //drawing points
            function TGeomBase.getArrGeomPoints() : TArray<TGeomPoint>;
                begin
                    result := arrGeomPoints;
                end;

        //rotation
            procedure TGeomBase.rotate( const rotationAngleIn           : double;
                                        const rotationReferencePointIn  : TGeomPoint );
                begin
                    TGeomPoint.rotateArrPoints(
                                                    rotationAngleIn,
                                                    rotationReferencePointIn,
                                                    arrGeomPoints
                                              );
                end;

            procedure TGeomBase.rotate(const rotationAngleIn : double);
                begin
                    rotate( rotationAngleIn, calculateCentroidPoint() );
                end;

            class procedure TGeomBase.rotate(   const rotationAngleIn           : double;
                                                const rotationReferencePointIn  : TGeomPoint;
                                                arrGeometryInOut                : TArray<TGeomBase> );
                var
                    i, arrlen : integer;
                begin
                    arrlen := length( arrGeometryInOut );

                    for i := 0 to ( arrlen - 1 ) do
                        arrGeometryInOut[i].rotate( rotationAngleIn, rotationReferencePointIn );
                end;

        //scaling
            procedure TGeomBase.scale(  const scaleFactorIn         : double;
                                        const scaleReferencePointIn : TGeomPoint    );
                begin
                    TGeomPoint.scalePoints( scaleFactorIn, scaleReferencePointIn, arrGeomPoints );
                end;

            procedure TGeomBase.scale(const scaleFactorIn : double);
                begin
                    scale( scaleFactorIn, calculateCentroidPoint() );
                end;

            class procedure TGeomBase.scale(const scaleFactorIn         : double;
                                            const scaleReferencePointIn : TGeomPoint;
                                            arrGeometryInOut            : TArray<TGeomBase>);
                var
                    i, arrlen : integer;
                begin
                    arrlen := length( arrGeometryInOut );

                    for i := 0 to ( arrlen - 1 ) do
                        arrGeometryInOut[i].scale( scaleFactorIn, scaleReferencePointIn );
                end;

        //shift the geometry
            procedure TGeomBase.shift(const deltaXIn, deltaYIn, deltaZIn : double);
                var
                    i : integer;
                begin
                    for i := 0 to (length(arrGeomPoints) - 1) do
                        arrGeomPoints[i].shiftPoint( deltaXIn, deltaYIn, deltaZIn );
                end;

            procedure TGeomBase.shift(const deltaXIn, deltaYIn : double);
                var
                    i : integer;
                begin
                    for i := 0 to (length(arrGeomPoints) - 1) do
                        arrGeomPoints[i].shiftPoint( deltaXIn, deltaYIn );
                end;

            class procedure TGeomBase.shift(const deltaXIn, deltaYIn    : double;
                                            arrGeometryInOut            : TArray<TGeomBase> );
                var
                    i, arrlen : integer;
                begin
                    arrlen := length( arrGeometryInOut );

                    for i := 0 to ( arrlen - 1 ) do
                        arrGeometryInOut[i].shift( deltaXIn, deltaYIn );
                end;

end.
