public with sharing class SomTv_OLI_AdfExportCtrl
{
    private SomTv_OLI_AdfExportData dataContainer;
    
    public SomTv_OLI_AdfExportCtrl(Id adfProjectId)
    {
        init(adfProjectId);
    }
    
    public SomTv_OLI_AdfExportCtrl(ApexPages.StandardController stdCtrl)
    {
        init(stdCtrl.getRecord().Id);
    }
    
    private void init(Id adfProjectId)
    {   
        this.dataContainer = new SomTv_OLI_AdfExportData(adfProjectId);
    }
    
    public String content {get{return xlsxContent();}}
    
    private String xlsxContent()
    {
        Base_ExcelXmlExport xls = new ExcelXmlExport(this.dataContainer);   
        return xls.export();
    }
    
    
    /*
    * TODO: auf XmlStreamWriter umbauen
    * 
    */ 
    private abstract class Base_ExcelXmlExport 
    {
        protected SomTv_OLI_AdfExportData data;
        
        public Base_ExcelXmlExport (SomTv_OLI_AdfExportData data)
        {
            this.data = data;
        }
        
        public virtual String export()
        {
            String strHeader = generateHeader('');
            String opening = generateOpening('');
            String cellString = generateCellString('');
            String closing = generateClosing('');
            
            return strHeader + opening + cellString + closing;
        }
        
        private virtual String generateHeader(String header)
        {
            header += '<?xml version="1.0"?>\n';
            header += '<?mso-application progid="Excel.Sheet"?>\n';
            return header;
        }
        
        private virtual String generateOpening(String opening)
        {
            opening += '<ss:Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:x="urn:schemas-microsoft-com:office:excel">\n';
            opening += '<ss:Styles>\n';
            opening += '<ss:Style ss:ID="std">\n';
            opening += '<ss:Alignment />\n';
            opening += '<ss:Borders />\n';
            opening += '<ss:Font ss:Size="12" ss:Bold="0" />\n';
            opening += '<ss:Interior />\n';
            opening += '<ss:NumberFormat />\n';
            opening += '<ss:Protection />\n';
            opening += '</ss:Style>\n';
            opening += '<ss:Style ss:ID="bold">\n';
            opening += '<ss:Alignment />\n';
            opening += '<ss:Borders />\n';
            opening += '<ss:Font ss:Size="12" ss:Bold="1" />\n';
            opening += '<ss:Interior />\n';
            opening += '<ss:NumberFormat />\n';
            opening += '<ss:Protection />\n';
            opening += '</ss:Style>\n';
            opening += '</ss:Styles>\n';
            opening += '<ss:Worksheet ss:Name="Factsheet">\n';
            opening += '<ss:Table x:FullColumns="1" x:FullRows="1">\n';
            for(Integer col = 0; col < data.count+1 ; col++)
            {
                opening += '<ss:Column ss:Width="170"></ss:Column>\n';
            }
            return opening;
        }
        
        private virtual String generateCellString(String cellString)
        {
            for(List<Object> cells : data.records)
            {
                cellString += '<ss:Row>\n';
                Boolean isFirstColumn = true;
                System.Iterator<Object> cellIt = cells.iterator();
                if(cellIt.hasNext())
                {
                    Object value = cellIt.next();
                    cellString += '<ss:Cell ss:StyleID="bold">';
                    cellString += cellValue(value);
                    cellString += '</ss:Cell>\n';
                }
                while(cellIt.hasNext())
                {
                    Object value = cellIt.next();
                    cellString += '<ss:Cell ss:StyleID="std">';
                    cellString += cellValue(value);
                    cellString += '</ss:Cell>\n';
                }
                cellString += '</ss:Row>\n';
            }
            return cellstring;
        }
        
        private String cellValue(Object value)
        {
            String cellString = NULL;
            
            if(Value instanceOf Decimal)
                cellString = '<ss:Data ss:Type="Number">';
            
            cellString = cellString == NULL ? '<ss:Data ss:Type="String">' : cellString;
            cellstring += value + '</ss:Data>';
            return cellstring;
        }
        
        private virtual String generateClosing(String closing)
        {
            closing += '</ss:Table>\n';
            closing += '</ss:Worksheet>\n';
            closing += '</ss:Workbook>\n';
            
            return closing;
        }
        
    }
    
    
    /*
    * This class ist used for development purpose. Methods from the super class can be overridden to test changes 
    * 
    */
    private class ExcelXmlExport extends Base_ExcelXmlExport
    {
        public ExcelXmlExport(SomTv_OLI_AdfExportData data)
        {
            super(data);
        }
    }
    
}