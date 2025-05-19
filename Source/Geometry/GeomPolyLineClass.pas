unit GeomPolyLineClass;

interface

    uses
        System.SysUtils, system.Math,
        GraphicDrawingTypes,
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
                    constructor create(); overload;
                    constructor create(const arrPointsIn : TArray<TGeomPoint>); overload;
                //destructor
                    destructor destroy(); override;
                //accessors
                    function getVertex(indexIn : integer) : TGeomPoint;
                //modifiers
                    //add a new vertex and line
                        function addVertex(const xIn, yIn : double) : boolean; overload;
                        function addVertex(const xIn, yIn, zIn : double) : boolean; overload;
                        function addVertex(const newVertexIn : TGeomPoint) : boolean; overload;
                    //edit a currently selected vertex
                        procedure editVertex(   indexIn         : integer;
                                                xIn, yIn, zIn   : double    ); overload;
                        procedure editVertex(   indexIn     : integer;
                                                newPointIn  : TGeomPoint); overload;
                //calculations
                    function calculatePolylineLength() : double; overload;
                    class function calculatePolylineLength(const arrPointsIn : TArray<TGeomPoint>) : double; overload; static;
                //helper methods
                    function vertexCount() : integer;
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

            constructor TGeomPolyLine.create(const arrPointsIn : TArray<TGeomPoint>);
                begin
                    create();

                    TGeomPoint.copyPoints( arrPointsIn, arrGeomPoints );
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
            function TGeomPolyLine.addVertex(const xIn, yIn : double) : boolean;
                begin
                    result := addVertex(xIn, yIn, 0);
                end;

            function TGeomPolyLine.addVertex(const xIn, yIn, zIn : double) : boolean;
                begin
                    result := addVertex(
                                            TGeomPoint.create(xIn, yIn, zIn)
                                       );
                end;

            function TGeomPolyLine.addVertex(const newVertexIn : TGeomPoint) : boolean;
                var
                    samePointTest   : boolean;
                    i, arrLen       : integer;
                    dp              : double;
                begin
                    result := true;

                    arrLen := vertexCount();

                    //test to see if the new point already exists
                        for i := 0 to (arrLen - 1) do
                            begin
                                dp := TGeomPoint.calculateDistanceBetweenPoints( newVertexIn, arrGeomPoints[i] );

                                samePointTest := (dp < 1e-6);

                                if (samePointTest = True) then
                                    exit( False );
                            end;

                    //increment vertex array
                        SetLength( arrGeomPoints, arrLen + 1 );

                    //add new vertex to array
                        arrGeomPoints[ arrLen ].copyPoint( newVertexIn );
                end;

            //edit a currently selected vertex
                procedure TGeomPolyLine.editVertex( indexIn         : integer;
                                                    xIn, yIn, zIn   : double    );
                    begin
                        arrGeomPoints[ indexIn ].setPoint( xIn, yIn, zIn );
                    end;

                procedure TGeomPolyLine.editVertex( indexIn     : integer;
                                                    newPointIn  : TGeomPoint);
                    begin
                        arrGeomPoints[ indexIn ].copyPoint( newPointIn );
                    end;

        //calculations
            function TGeomPolyLine.calculatePolylineLength() : double;
                begin
                    result := calculatePolylineLength( arrGeomPoints );
                end;

            class function TGeomPolyLine.calculatePolylineLength(const arrPointsIn : TArray<TGeomPoint>) : double;
                var
                    i           : integer;
                    lengthSum   : double;
                begin
                    lengthSum := 0;

                    for i := 0 to (length(arrPointsIn) - 2) do
                        lengthSum := lengthSum + TGeomPoint.calculateDistanceBetweenPoints( arrPointsIn[i], arrPointsIn[i + 1] );

                    result := lengthSum;
                end;

        //helper methods
            function TGeomPolyLine.vertexCount() : integer;
                begin
                    result := Length( arrGeomPoints );
                end;

            procedure TGeomPolyLine.clearVertices();
                begin
                    SetLength( arrGeomPoints, 0 );
                end;

end.
