public with sharing class Batch {
	public String name {get;set;}
	public String whereClause {get;set;}
	public Integer batchSize {get;set;}
	public String baseQuery {get;set;}
	public String query;
	
	public Batch() {
		baseQuery	= '';
		whereClause	= '';
		batchSize	= 50;
		query		= '';
	}
	
	public String getQuery() {
		return baseQuery + ' ' + whereClause;
	}
}