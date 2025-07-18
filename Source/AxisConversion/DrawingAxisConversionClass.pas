unit DrawingAxisConversionClass;

interface

    uses
        System.SysUtils, system.Math, system.Types, vcl.Controls,
        GeometryTypes, GeomBox,
        DrawingAxisConversionMouseControlClass;

    type
        TDrawingAxisConverter = class(TDrawingAxisMouseControlConverter)
            public
                //constructor
                    constructor create(); override;
                //destructor
                    destructor destroy(); override;
        end;

implementation

    //public
        //constructor
            constructor TDrawingAxisConverter.create();
                begin
                    inherited create();
                end;

        //destructor
            destructor TDrawingAxisConverter.destroy();
                begin
                    inherited destroy();
                end;

end.
