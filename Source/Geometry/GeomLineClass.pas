unit GeomLineClass;

interface

    uses
        system.sysUtils, system.Math, system.Types,
        LinearAlgebraTypes,
        VectorMethods,
        GeometryMathMethods,
        GeometryTypes, GeomBox,
        GeometryBaseClass, GeomSpaceVectorClass;

    type
        TGeomLine = class(TGeomBase)
            strict private
                const
                    //line vector index constants
                        x : integer = 0;
                        y : integer = 1;
                        z : integer = 2;
                var
                    lineVector : TGeomSpaceVector;
                //helper methods
                    //calculat line projections on 3 axes
                        procedure calculateAxisProjections();
                    //assign points
                        procedure assignPoints(const startPointIn, endPointIn : TGeomPoint);
            strict protected
                //
            public
                //constructor
                    constructor create(); overload;
                    constructor create(const startPointIn, endPointIn : TGeomPoint); overload;
                //destructor
                    destructor destroy(); override;
                //accessors
                    function getStartPoint() : TGeomPoint;
                    function getEndPoint() : TGeomPoint;
                //modifiers
                    //start point
                        procedure setStartPoint(const xIn, yIn : double); overload;
                        procedure setStartPoint(const xIn, yIn, zIn : double); overload;
                        procedure setStartPoint(const startPointIn : TGeomPoint); overload;
                    //end point
                        procedure setEndPoint(const xIn, yIn : double); overload;
                        procedure setEndPoint(const xIn, yIn, zIn : double); overload;
                        procedure setEndPoint(const endPointIn : TGeomPoint); overload;
                    procedure setPoints(const startPointIn, endPointIn : TGeomPoint);
                //calculations
                    //line length
                        function calculateLength() : double; overload;
                    //unit vector
                        function unitVector() : TGeomSpaceVector;
                    //parametric line equation point
                        function parametricEquationPoint(const tIn : double) : TGeomPoint;
                    //line intersection
                        function calculateLineIntersection( const lineIn        : TGeomLine;
                                                            const freeLineIn    : boolean = True) : TGeomLineIntersectionData; overload;
                        class function calculateLineIntersection(   const line1In, line2In  : TGeomLine;
                                                                    const freeLinesIn       : boolean = True    ) : TGeomLineIntersectionData; overload; static;
                    //line midpoint
                        class function calculateLineMidpoint(const startPointIn, endPointIn : TGeomPoint) : TGeomPoint; overload; static;
                        function calculateLineMidpoint() : TGeomPoint; overload;
        end;

implementation

    //private
        //helper methods
            //calculat line projections on 3 axes
                //x-axis (x-component)
                    procedure TGeomLine.calculateAxisProjections();
                        begin
                            lineVector[x] := arrGeomPoints[1].x - arrGeomPoints[0].x;
                            lineVector[y] := arrGeomPoints[1].y - arrGeomPoints[0].y;
                            lineVector[z] := arrGeomPoints[1].z - arrGeomPoints[0].z;
                        end;

            //assign points
                procedure TGeomLine.assignPoints(const startPointIn, endPointIn : TGeomPoint);
                    begin
                        arrGeomPoints[0].copyPoint( startPointIn );
                        arrGeomPoints[1].copyPoint( endPointIn );

                        calculateAxisProjections();
                    end;

    //protected

    //public
        //constructor
            constructor TGeomLine.create();
                begin
                    inherited create();

                    lineVector := TGeomSpaceVector.create();

                    lineVector.setDimensions(3);

                    SetLength(arrGeomPoints, 2);
                end;

            constructor TGeomLine.create(const startPointIn, endPointIn : TGeomPoint);
                begin
                    create();

                    assignPoints( startPointIn, endPointIn );
                end;

        //destructor
            destructor TGeomLine.destroy();
                begin
                    FreeAndNil(lineVector);

                    inherited destroy();
                end;

        //accessors
            function TGeomLine.getStartPoint() : TGeomPoint;
                begin
                    result := arrGeomPoints[0];
                end;

            function TGeomLine.getEndPoint() : TGeomPoint;
                begin
                    result := arrGeomPoints[1];
                end;

        //modifiers
            //start point
                procedure TGeomLine.setStartPoint(const xIn, yIn : double);
                    begin
                        setStartPoint( xIn, yIn, 0 );
                    end;

                procedure TGeomLine.setStartPoint(const xIn, yIn, zIn : double);
                    var
                        newStartPoint : TGeomPoint;
                    begin
                        newStartPoint := TGeomPoint.create( xIn, yIn, zIn );

                        setStartPoint( newStartPoint );
                    end;

                procedure TGeomLine.setStartPoint(const startPointIn : TGeomPoint);
                    begin
                        assignPoints(startPointIn, arrGeomPoints[1]);
                    end;

            //end point
                procedure TGeomLine.setEndPoint(const xIn, yIn : double);
                    begin
                        setEndPoint( xIn, yIn, 0 );
                    end;

                procedure TGeomLine.setEndPoint(const xIn, yIn, zIn : double);
                    var
                        newEndPoint : TGeomPoint;
                    begin
                        newEndPoint := TGeomPoint.create( xIn, yIn, zIn );

                        setEndPoint( newEndPoint );
                    end;

                procedure TGeomLine.setEndPoint(const endPointIn : TGeomPoint);
                    begin
                        assignPoints(arrGeomPoints[0], endPointIn);
                    end;

            procedure TGeomLine.setPoints(const startPointIn, endPointIn : TGeomPoint);
                begin
                    assignPoints(startPointIn, endPointIn);
                end;

        //calculations
            //line length
                function TGeomLine.calculateLength() : double;
                    begin
                        result := TGeomPoint.calculateDistanceBetweenPoints( arrGeomPoints[0], arrGeomPoints[1] );
                    end;

            //unit vector
                function TGeomLine.unitVector() : TGeomSpaceVector;
                    begin
                        result := lineVector.calculateUnitVector();
                    end;

            //parametric line equation point
                function TGeomLine.parametricEquationPoint(const tIn : double) : TGeomPoint;
                    var
                        lineUnitVector  : TGeomSpaceVector;
                        pointOut        : TGeomPoint;
                    begin
                        lineUnitVector := unitVector();

                        //(x, y, z) = (x0, y0, z0) + t<ux, uy, uz>
                            pointOut.x := arrGeomPoints[0].x + tIn * lineUnitVector[0];
                            pointOut.y := arrGeomPoints[0].y + tIn * lineUnitVector[1];
                            pointOut.z := arrGeomPoints[0].z + tIn * lineUnitVector[2];

                        FreeAndNil(lineUnitVector);

                        result := pointOut;
                    end;

            //line intersection
                function TGeomLine.calculateLineIntersection(   const lineIn        : TGeomLine;
                                                                const freeLineIn    : boolean = True) : TGeomLineIntersectionData;
                    var
                        lineIntersectionDataOut : TGeomLineIntersectionData;
                    begin
                        //get intersection data
                            lineIntersectionDataOut := calculateLineIntersection(self, lineIn, false);

                        //determine intersection point region
                            if (lineIntersectionDataOut.intersectionExists) then
                                begin
                                    if (self.boundingBox().pointIsWithin(lineIntersectionDataOut.point)) then
                                        lineIntersectionDataOut.relativeToBound := EBoundaryRelation.brInside
                                    else
                                        lineIntersectionDataOut.relativeToBound := EBoundaryRelation.brOutside;
                                end;

                        //free line if necessary
                            if (freeLineIn) then
                                FreeAndNil(lineIn);

                        result := lineIntersectionDataOut;
                    end;

                class function TGeomLine.calculateLineIntersection( const line1In, line2In  : TGeomLine;
                                                                    const freeLinesIn       : boolean = True    ) : TGeomLineIntersectionData;
                    var
                        line1Point0, line1Point1,
                        line2Point0, line2Point1    : TGeomPoint;
                        lineIntersectionDataOut     : TGeomLineIntersectionData;
                    begin
                        //get points from lines
                            //line 1
                                line1Point0 := line1In.getStartPoint();
                                line1Point1 := line1In.getEndPoint();

                            //line 2
                                line2Point0 := line2In.getStartPoint();
                                line2Point1 := line2In.getEndPoint();

                        //calculate intersection data
                            lineIntersectionDataOut := geomLineIntersectionPoint(   line1Point0, line1Point1,
                                                                                    line2Point0, line2Point1    );

                        //free lines if necessary
                            if (freeLinesIn) then
                                begin
                                    FreeAndNil( line1In );
                                    FreeAndNil( line2In );
                                end;

                        result := lineIntersectionDataOut;
                    end;

            //line midpoint
                class function TGeomLine.calculateLineMidpoint(const startPointIn, endPointIn : TGeomPoint) : TGeomPoint;
                    begin
                        result := TGeomPoint.calculateCentroidPoint( [startPointIn, endPointIn] );
                    end;

                function TGeomLine.calculateLineMidpoint() : TGeomPoint;
                    begin
                        result := calculateLineMidpoint( getStartPoint(), getEndPoint() );
                    end;

end.
