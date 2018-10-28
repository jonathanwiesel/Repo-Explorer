global with sharing class GitRepoModel {
    
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String slug;
    @AuraEnabled
    public String owner;
    @AuraEnabled
    public Boolean isPrivate;
    @AuraEnabled
    public String url;

    public GitRepoModel(String name, String slug, String owner, Boolean isPrivate, String url) {
        this.name = name;
        this.slug = slug;
        this.owner = owner;
        this.isPrivate = isPrivate;
        this.url = url;
    }
}