unit DrawingAxisConversionBaseClass;

interface

    uses
        System.SysUtils, system.Math, system.Types,
        GeometryTypes,
        GeomBox;

    type
        TDrawingAxisConverterBase = class
            protected
                var
                    canvasDimensions    : TSize;
                    drawingRegion       : TGeomBox;
            public
                //constructor
                    constructor create(); virtual;
                //destructor
                    destructor destroy(); override;
                //accessors
                    function getCanvasDimensions() : TSize;
                    function getDrawingRegion() : TGeomBox;
                //modifiers
                    //canvas boundaries
                        procedure setCanvasDimensions(const canvasWidthIn, canvasHeightIn : integer);
                    //drawing space boundaries
                        procedure setDrawingRegion( const bufferIn : double;
                                                    const regionIn : TGeomBox ); overload;
                //helper methods
                    //domain
                        function calculateRegionDomain() : double;
                    //range
                        function calculateRegionRange() : double;
                    //validity
                        function isValid() : boolean;
        end;

implementation

    //public
        //constructor
            constructor TDrawingAxisConverterBase.create();
                begin
                    inherited create();

                    //canvas and drawing region dimensions set to an initial value
                    //to prevent any initial errors from occuring
                        setCanvasDimensions( 10, 10 );
                        drawingRegion := TGeomBox.newBox( 10, 10 );
                end;

        //destructor
            destructor TDrawingAxisConverterBase.destroy();
                begin
                    inherited destroy();
                end;

        //accessors
            function TDrawingAxisConverterBase.getCanvasDimensions() : TSize;
                begin
                    result := canvasDimensions;
                end;

            function TDrawingAxisConverterBase.getDrawingRegion() : TGeomBox;
                begin
                    result := drawingRegion;
                end;

        //modifiers
            //canvasSpace boundaries
                procedure TDrawingAxisConverterBase.setCanvasDimensions(const canvasWidthIn, canvasHeightIn : integer);
                    begin
                        canvasDimensions.Width  := canvasWidthIn;
                        canvasDimensions.Height := canvasHeightIn;
                    end;

            //drawingRegion space boundaries
                procedure TDrawingAxisConverterBase.setDrawingRegion(   const bufferIn : double;
                                                                        const regionIn : TGeomBox   );
                    var
                        buffer : double;
                    begin
                        //set valid buffer
                            buffer := min(5, bufferIn);
                            buffer := max(buffer, 0);

                        //copy in the new region and apply buffer
                            drawingRegion.copyBox( regionIn );
                            drawingRegion.scaleBox( 1 + (buffer / 100) );
                    end;

        //helper methods
            //domain
                function TDrawingAxisConverterBase.calculateRegionDomain() : double;
                    begin
                        result := drawingRegion.calculateXDimension();
                    end;

            //range
                function TDrawingAxisConverterBase.calculateRegionRange() : double;
                    begin
                        result := drawingRegion.calculateYDimension();
                    end;

            //validity
                function TDrawingAxisConverterBase.isValid() : boolean;
                    var
                        canvasDimensionsAreValid,
                        drawingRegionDimensionsAreValid : boolean;
                    begin
                        //check that the canvas dimensions are set
                            canvasDimensionsAreValid := NOT(
                                                                    IsZero( canvasDimensions.Width )
                                                                OR  IsZero( canvasDimensions.Height)
                                                           );

                        //check that the region dimensions are set
                            drawingRegionDimensionsAreValid := NOT(
                                                                            IsZero( drawingRegion.calculateXDimension() )
                                                                        OR  IsZero( drawingRegion.calculateYDimension() )
                                                                  );

                        result :=       canvasDimensionsAreValid
                                    AND drawingRegionDimensionsAreValid;
                    end;

end.
