body 
{
    font-family: Arial, Helvetica, sans-serif;
    font-size: 12px;
    color:#4a4a4a;
    width : 950px;	
    margin:0px;
}
a
{
    text-decoration: none;
    color: #FF0000;
}

div#headline
{
    font-weight : bold;
    font-size : 18px;
    border-bottom-style : dotted;
    border-width : 1px;    
    border-color: rgb(108,108,108);
    padding-top: 10px;
    padding-bottom: 10px;
    padding-left: 5px;
}

div#content
{
    margin-top : 10px;
    width : 100%;
}

div.ContentSection
{
    margin-bottom : 10px;
}

div#SpecialsAndSender
{
    display: flex;
}
div#SpecialsAndSender > div
{
    
    width: 50%;
}

div.SectionEnd
{
    
    padding-bottom: 10px;
    border-bottom-color: rgb(108,108,108);
    border-bottom-style: dotted;
    border-width : 1px;    
}



table.contentTable
{
    width : 950px;
    
}

table
{
    border-collapse : collapse;
}

td.full
{
    padding-top:5pt;
    padding-bottom:5pt;
    padding-left:10pt;
    padding-right:10pt;
    border-bottom-style : dotted;
    border-width : 1px;
    border-top-style : dotted;
    border-color : lightgrey;
}

td.full.odd
{
    background-color:#e9e9e9;
}

th
{  
    padding-top:5pt;
    padding-bottom:5pt;
    padding-left:10pt;
    padding-right:10pt;
    font-weight: normal;
    border-bottom-style : dotted;
    border-top-style : dotted;
    border-width : 1px;
    border-color : darkgrey;
    text-align: left;
}

th.odd
{  
    background-color:#e9e9e9;
}

td.NewsletterChecked
{
    text-align : center;
}

td.NewsletterTitle
{
    width : 25%;
}

td.NewsletterDescription
{
    width : 50%;
    font-size: 11px;
}
 

input.submitbutton
{
    background-image: url("https://news.sevenonemedia.de/art_resource.php?sid=1jy3v.2erqdcj");
    width: 91px;
    height: 23px;
    border: 0px none;
    margin-top: 18px;
    margin-left: 10px;
    cursor: pointer;    
}

#overlay
{
    position: absolute;
    left:0px;
    top:0px;
    width: 100%;
    height: 100%;
    display: none;
    opacity:0.6;
    text-align: center;
    background-color : #e9e9e9;
}
#overlay>span
{
    position: relative;
    top: 50%;
    font-weight: bold;
    color: white;
    padding-left: 200pt;
    padding-right: 200pt;
    padding-top: 20pt;
    padding-bottom: 20pt;
    background-color : #ff0033;
}