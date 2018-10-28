global with sharing class GitlabHostingService extends GitHostingService {
    
    private static final String LINKS_HEADER_NAME = 'Link';
    private static final String NEXT_PAGE_LINK_IDENTIFIER = 'rel="next"';
    private static final String PUBLIC_VISIBILITY = 'public';

    global override GitServiceResponseModel parseGetReposRequest(Integer page, Integer pageSize, HTTPResponse res) {

        RepoModel[] models = (RepoModel[])JSON.deserialize(res.getBody(), RepoModel[].class);

        GitRepoModel[] data = new GitRepoModel[]{};

        for (RepoModel repo : models) {
            data.add(new GitRepoModel(
                repo.name,
                repo.path_with_namespace,
                repo.owner != null ? repo.owner.name : repo.namespace.name,
                repo.visibility != PUBLIC_VISIBILITY,
                repo.web_url
            ));
        }

        String links = res.getHeader(LINKS_HEADER_NAME);
        Boolean hasNextPage = String.isNotBlank(links) && links.contains(NEXT_PAGE_LINK_IDENTIFIER);

        return new GitServiceResponseModel(pageSize, page, hasNextPage, data);
    }


    global override GitServiceResponseModel handleError(HTTPResponse res) {

        ErrorModel model = (ErrorModel)JSON.deserialize(res.getBody(), ErrorModel.class);

        return new GitServiceResponseModel(String.isNotBlank(model.message) ? model.message : model.error);
    }


    /**
     * *******************************
     * Serializing models
     * *******************************
     */

    private class RepoModel {

        String id;
        String visibility;
        String name;
        String path;
        String path_with_namespace;
        String web_url;
        String description;
        OwnerModel owner;
        NamespaceModel namespace;
    }


    private class OwnerModel {

        String id;
        String name;
        String username;
        String web_url;
    }

    
    private class NamespaceModel {

        String id;
        String name;
    }


    private class ErrorModel {

        String error;
        String message;
    }
}