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
                //centre point
                    function calculateCentrePoint() : TGeomPoint;
                    procedure setCentrePoint(const xIn, yIn : double); overload;
                    procedure setCentrePoint(const xIn, yIn, zIn : double); overload;
                    procedure setCentrePoint(const newCentrePointIn : TGeomPoint); overload;
                //drawing points
                    function getDrawingPoints() : TArray<TGeomPoint>;
                //rotation
                    procedure rotate(   const rotationAngleIn           : double;
                                        const rotationReferencePointIn  : TGeomPoint    ); overload;
                    procedure rotate(const rotationAngleIn : double); overload;
                //scaling
                    procedure scale(const scaleFactorIn         : double;
                                    const scaleReferencePointIn : TGeomPoint); overload;
                    procedure scale(const scaleFactorIn : double); overload;
                //shift the geometry
                    procedure shift(const deltaXIn, deltaYIn, deltaZIn : double); overload;
                    procedure shift(const deltaXIn, deltaYIn : double); overload;
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

        //centre point
            function TGeomBase.calculateCentrePoint() : TGeomPoint;
                begin
                    result := TGeomPoint.calculateCentrePoint( arrGeomPoints );
                end;

            procedure TGeomBase.setCentrePoint(const xIn, yIn : double);
                begin
                    setCentrePoint( xIn, yIn, 0 );
                end;

            procedure TGeomBase.setCentrePoint(const xIn, yIn, zIn : double);
                var
                    newCentrePoint : TGeomPoint;
                begin
                    newCentrePoint := TGeomPoint.create( xIn, yIn, zIn );

                    setCentrePoint( newCentrePoint );
                end;

            procedure TGeomBase.setCentrePoint(const newCentrePointIn : TGeomPoint);
                begin
                    TGeomBox.setCentrePoint( newCentrePointIn, arrGeomPoints );
                end;

        //drawing points
            function TGeomBase.getDrawingPoints() : TArray<TGeomPoint>;
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
                    TGeomPoint.rotateArrPoints(
                                                    rotationAngleIn,
                                                    arrGeomPoints
                                              );
                end;

        //scaling
            procedure TGeomBase.scale(  const scaleFactorIn         : double;
                                        const scaleReferencePointIn : TGeomPoint    );
                begin
                    TGeomPoint.scalePoints( scaleFactorIn, scaleReferencePointIn, arrGeomPoints );
                end;

            procedure TGeomBase.scale(const scaleFactorIn : double);
                begin
                    TGeomPoint.scalePoints( scaleFactorIn, arrGeomPoints );
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



end.
