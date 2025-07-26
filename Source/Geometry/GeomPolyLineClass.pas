unit GeomPolyLineClass;

interface

    uses
        System.SysUtils, system.Math,
        GeometryTypes, GeomBox,
        GeometryMathMethods,
        GeometryBaseClass,
        GeomLineClass;

    type
        TGeomPolyLine = class(TGeomBase)
            private
                //
            protected
                //
            public
                //constructor
                    constructor create();
                //destructor
                    destructor destroy(); override;
                //accessors
                    function getVertex(indexIn : integer) : TGeomPoint;
                //modifiers
                    //add a new vertex and line
                        function addVertex(const xIn, yIn : double; const zIn : double = 0) : boolean; overload;
                        function addVertex(const newVertexIn : TGeomPoint) : boolean; overload;
                    //edit a currently selected vertex
                        procedure editVertex(   const indexIn   : integer;
                                                const xIn, yIn  : double;
                                                const zIn       : double = 0 ); overload;
                        procedure editVertex(   const indexIn       : integer;
                                                const newPointIn    : TGeomPoint ); overload;
                    //set points
                        procedure setVertices(const arrXIn, arrYIn : TArray<double>; const arrZIn : TArray<double> = []); overload;
                        procedure setVertices(const arrPointsIn : TArray<TGeomPoint>); overload;
                //calculations
                    function calculateCentroidPoint() : TGeomPoint; override;
                    function calculatePolylineLength() : double; overload;
                    class function calculatePolylineCentroid(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint; static;
                    class function calculatePolylineLength(const arrPointsIn : TArray<TGeomPoint>) : double; overload; static;
                //helper methods
                    function vertexCount() : integer;
                    function lineCount() : integer;
                    procedure clearVertices();
        end;

implementation

    //private
        //

    //protected

    //public
        //constructor
            constructor TGeomPolyLine.create();
                begin
                    inherited create();

                    SetLength(arrGeomPoints,  0);
                end;

        //destructor
            destructor TGeomPolyLine.destroy();
                begin
                    inherited destroy();
                end;

        //accessors
            function TGeomPolyLine.getVertex(indexIn : integer) : TGeomPoint;
                begin
                    result := arrGeomPoints[indexIn];
                end;

        //add a line to the array of lines
            function TGeomPolyLine.addVertex(const xIn, yIn : double; const zIn : double = 0) : boolean;
                var
                    newPoint : TGeomPoint;
                begin
                    newPoint.setPoint( xIn, yIn, zIn );

                    result := addVertex( newPoint );
                end;

            function TGeomPolyLine.addVertex(const newVertexIn : TGeomPoint) : boolean;
                var
                    samePointExists : boolean;
                    i, arrLen       : integer;
                    dp              : double;
                begin
                    result := true;

                    arrLen := vertexCount();

                    //test to see if the new point already exists
                        for i := 0 to (arrLen - 1) do
                            begin
                                dp := TGeomPoint.calculateDistanceBetweenPoints( newVertexIn, arrGeomPoints[i] );

                                samePointExists := (dp < 1e-6);

                                if ( samePointExists ) then
                                    exit( False );
                            end;

                    //increment vertex array
                        SetLength( arrGeomPoints, arrLen + 1 );

                    //add new vertex to array
                        arrGeomPoints[ arrLen ].copyPoint( newVertexIn );
                end;

            //edit a currently selected vertex
                procedure TGeomPolyLine.editVertex( const indexIn   : integer;
                                                    const xIn, yIn  : double;
                                                    const zIn       : double = 0 );
                    begin
                        arrGeomPoints[ indexIn ].setPoint( xIn, yIn, zIn );
                    end;

                procedure TGeomPolyLine.editVertex( const indexIn       : integer;
                                                    const newPointIn    : TGeomPoint );
                    begin
                        arrGeomPoints[ indexIn ].copyPoint( newPointIn );
                    end;

            //set points
                procedure TGeomPolyLine.setVertices(const arrXIn, arrYIn : TArray<double>; const arrZIn : TArray<double> = []);
                    var
                        newArrGeomPoint : TArray<TGeomPoint>;
                    begin
                        newArrGeomPoint := TGeomPoint.createPointArray( arrXIn, arrYIn, arrZIn );

                        setVertices( newArrGeomPoint );
                    end;

                procedure TGeomPolyLine.setVertices(const arrPointsIn : TArray<TGeomPoint>);
                    begin
                        TGeomPoint.copyPoints( arrPointsIn, arrGeomPoints );
                    end;

        //calculations
            function TGeomPolyLine.calculateCentroidPoint() : TGeomPoint;
                begin
                    result := calculatePolylineCentroid( arrGeomPoints );
                end;

            function TGeomPolyLine.calculatePolylineLength() : double;
                begin
                    result := calculatePolylineLength( arrGeomPoints );
                end;

            class function TGeomPolyLine.calculatePolylineCentroid(const arrPointsIn : TArray<TGeomPoint>) : TGeomPoint;
                var
                    i, arrLen                       : integer;
                    centroidX, centroidY, centroidZ,
                    lineLength, totalLength         : double;
                    lineMidPoint                    : TGeomPoint;
                    arr_XdL, arr_YdL, arr_ZdL       : TArray<double>;
                begin
                    arrLen      := length( arrPointsIn ) - 1;
                    totalLength := calculatePolylineLength( arrPointsIn );

                    SetLength( arr_XdL, arrLen );
                    SetLength( arr_YdL, arrLen );
                    SetLength( arr_ZdL, arrLen );

                    for i := 0 to (arrLen - 1) do
                        begin
                            lineMidPoint    := TGeomLine.calculateLineMidpoint( arrPointsIn[i], arrPointsIn[i+1] );
                            lineLength      := TGeomPoint.calculateDistanceBetweenPoints( arrPointsIn[i], arrPointsIn[i+1] );

                            arr_XdL[i] := lineMidPoint.x * lineLength;
                            arr_YdL[i] := lineMidPoint.y * lineLength;
                            arr_ZdL[i] := lineMidPoint.z * lineLength;
                        end;

                    centroidX := sum( arr_XdL ) / totalLength;
                    centroidY := sum( arr_YdL ) / totalLength;
                    centroidZ := sum( arr_ZdL ) / totalLength;

                    result := TGeomPoint.create( centroidX, centroidY, centroidZ );
                end;

            class function TGeomPolyLine.calculatePolylineLength(const arrPointsIn : TArray<TGeomPoint>) : double;
                var
                    i           : integer;
                    lengthSum   : double;
                begin
                    lengthSum := 0;

                    for i := 0 to ( length(arrPointsIn) - 2) do
                        lengthSum := lengthSum + TGeomPoint.calculateDistanceBetweenPoints( arrPointsIn[i], arrPointsIn[i + 1] );

                    result := lengthSum;
                end;

        //helper methods
            function TGeomPolyLine.vertexCount() : integer;
                begin
                    result := Length( arrGeomPoints );
                end;

            function TGeomPolyLine.lineCount() : integer;
                begin
                    result := vertexCount() - 1;
                end;

            procedure TGeomPolyLine.clearVertices();
                begin
                    SetLength( arrGeomPoints, 0 );
                end;

end.
