unit DrawingAxisConversionZoomingClass;

interface

    uses
        System.SysUtils, system.Math, system.Types,
        GeometryTypes, GeomBox,
        DrawingAxisConversionCalculationsClass
        ;

    type
        TDrawingAxisZoomingConverter = class(TDrawingAxisConvertionCalculator)
            private
                //var
                    graphicBorderPercentage : double;
                //calculate the zoom scale factor
                    function calculateZoomScaleFactor(const newZoomPercentageIn : double) : double;
                //zooming by percent
                    procedure zoom( const newZoomPercentageIn   : double;
                                    const zoomAboutPointIn      : TGeomPoint ); overload;
                    procedure zoom(const newZoomPercentageIn : double); overload;
            protected
                var
                    graphicBoundaryCentre   : TGeomPoint;
                    graphicBoundary         : TGeomBox; //the geometry boundary stores the geometry group's boundary
            public
                //constructor
                    constructor create(); override;
                //destructor
                    destructor destroy(); override;
                //modifiers
                    procedure setGeometryBorderPercentage(const geometryBorderPercentageIn : double);
                    procedure setGeometryBoundary(const boundaryBoxIn : TGeomBox);
                    procedure resetDrawingRegionToGeometryBoundary();
                //zooming methods
                    function calculateCurrentZoomPercentage() : double;
                    procedure zoomIn(   const zoomPercentageIn : double;
                                        const zoomAboutPointIn : TGeomPoint ); overload;
                    procedure zoomIn(const zoomPercentageIn : double); overload;
                    procedure zoomOut(  const zoomPercentageIn : double;
                                        const zoomAboutPointIn : TGeomPoint ); overload;
                    procedure zoomOut(const zoomPercentageIn : double); overload;
                    procedure setZoom(const newZoomPercentageIn : double);
        end;

implementation

    //private
        //calculate the zoom scale factor
            function TDrawingAxisZoomingConverter.calculateZoomScaleFactor(const newZoomPercentageIn : double) : double;
                begin
                    //the scale factor is used to size the domain and range
                    // < 1 the region shrinks which zooms the drawing in
                    // > 1 the region grows which zooms the drawing out

                    result := calculateCurrentZoomPercentage() / newZoomPercentageIn;
                end;

        //zooming by percent
            procedure TDrawingAxisZoomingConverter.zoom(const newZoomPercentageIn   : double;
                                                        const zoomAboutPointIn      : TGeomPoint);
                var
                    zoomScaleFactor : double;
                begin
                    //check new zoom percentage
                        if ( newZoomPercentageIn < 1e-3 ) then
                            exit();

                    //zoom to the desired factor about the specified point
                        //get the zoom factor
                            zoomScaleFactor := calculateZoomScaleFactor( newZoomPercentageIn );

                    //scale the drawing region
                        drawingRegion.scaleBox( zoomScaleFactor, zoomAboutPointIn );
                end;

            procedure TDrawingAxisZoomingConverter.zoom(const newZoomPercentageIn : double);
                var
                    zoomScaleFactor : double;
                begin
                    //check new zoom percentage
                        if ( newZoomPercentageIn < 1e-3 ) then
                            exit();

                    //zoom to the desired factor about the specified point
                        //get the zoom factor
                            zoomScaleFactor := calculateZoomScaleFactor( newZoomPercentageIn );

                    //scale the drawing region
                        drawingRegion.scaleBox( zoomScaleFactor );
                end;

    //public
        //constructor
            constructor TDrawingAxisZoomingConverter.create();
                begin
                    inherited create();

                    setGeometryBorderPercentage( 5 );

                    graphicBoundary.minPoint.setPoint( 0, 0, 0 );
                    graphicBoundary.maxPoint.setPoint( 0, 0, 0 );
                end;

        //destructor
            destructor TDrawingAxisZoomingConverter.destroy();
                begin
                    inherited destroy();
                end;

        //modifiers
            procedure TDrawingAxisZoomingConverter.setGeometryBorderPercentage(const geometryBorderPercentageIn : double);
                const
                    MIN_VALUE : double = 0;
                    MAX_VALUE : double = 5;
                begin
                    graphicBorderPercentage := max( MIN_VALUE, geometryBorderPercentageIn );
                    graphicBorderPercentage := min( geometryBorderPercentageIn, MAX_VALUE );
                end;

            procedure TDrawingAxisZoomingConverter.setGeometryBoundary(const boundaryBoxIn : TGeomBox);
                begin
                    graphicBoundary.copyBox( boundaryBoxIn );

                    //the geometry boundary cannot have a zero dimensions-----------
                    //or it breaks the drawing region
                        if ( IsZero( graphicBoundary.calculateXDimension() ) ) then
                            graphicBoundary.setXDimension(1e-2);

                        if ( IsZero( graphicBoundary.calculateYDimension() ) ) then
                            graphicBoundary.setYDimension(1e-2);
                    //--------------------------------------------------------------

                    graphicBoundaryCentre.copyPoint( graphicBoundary.calculateCentrePoint() );
                end;

            procedure TDrawingAxisZoomingConverter.resetDrawingRegionToGeometryBoundary();
                begin
                    setDrawingRegion( graphicBorderPercentage, graphicBoundary );
                end;

        //zooming methods
            function TDrawingAxisZoomingConverter.calculateCurrentZoomPercentage() : double;
                var
                    borderBufferPercentage,
                    domainDimensionsRatio, rangeDimensionsRatio,
                    largestDimensionsRatio                      : double;
                begin
                    //zoom is the ratio of the graphic boundary to the drawing region
                        domainDimensionsRatio    := graphicBoundary.calculateXDimension() / drawingRegion.calculateXDimension();
                        rangeDimensionsRatio     := graphicBoundary.calculateYDimension() / drawingRegion.calculateYDimension();

                    //max function is used because graphicBoundary and drawingRegion can have different dimension ratios
                    //the larger value between the respective dimension ratios is the zoom percentage
                        largestDimensionsRatio := max( domainDimensionsRatio, rangeDimensionsRatio );

                    //borderBufferPercentage is for the buffer on the drawing region when reset using the geometry boundary
                        borderBufferPercentage := 100 + graphicBorderPercentage;

                    result := borderBufferPercentage * largestDimensionsRatio
                end;


            procedure TDrawingAxisZoomingConverter.zoomIn(  const zoomPercentageIn : double;
                                                            const zoomAboutPointIn : TGeomPoint );
                var
                    currentZoomPercentage, newZoomPercentage : double;
                begin
                    if (zoomPercentageIn <= 0) then
                        exit();

                    currentZoomPercentage := calculateCurrentZoomPercentage();

                    //to zoom in the current zoom percentage is multiplied by a scale factor
                        newZoomPercentage := currentZoomPercentage * (1 + zoomPercentageIn / 100);

                    zoom( newZoomPercentage, zoomAboutPointIn );
                end;

            procedure TDrawingAxisZoomingConverter.zoomIn(const zoomPercentageIn : double);
                begin
                    if (zoomPercentageIn <= 0) then
                        exit();

                    zoomIn(
                                zoomPercentageIn,
                                drawingRegion.calculateCentrePoint()
                          );
                end;

            procedure TDrawingAxisZoomingConverter.zoomOut( const zoomPercentageIn : double;
                                                            const zoomAboutPointIn : TGeomPoint );
                var
                    currentZoomPercentage, newZoomPercentage : double;
                begin
                    if (zoomPercentageIn <= 0) then
                        exit();

                    currentZoomPercentage := calculateCurrentZoomPercentage();

                    //to zoom out the current zoom percentage is divided by a scale factor
                        newZoomPercentage := currentZoomPercentage / (1 + zoomPercentageIn / 100);

                    zoom( newZoomPercentage, zoomAboutPointIn );
                end;

            procedure TDrawingAxisZoomingConverter.zoomOut(const zoomPercentageIn : double);
                begin
                    if (zoomPercentageIn <= 0) then
                        exit();

                    zoomOut(
                                zoomPercentageIn,
                                drawingRegion.calculateCentrePoint()
                           );
                end;

            procedure TDrawingAxisZoomingConverter.setZoom(const newZoomPercentageIn : double);
                begin
                    if (newZoomPercentageIn < 1e-3) then
                        exit();

                    zoom( newZoomPercentageIn );
                end;

end.
