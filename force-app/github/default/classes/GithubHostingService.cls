global with sharing class GithubHostingService extends GitHostingService {
    
    private static final String LINKS_HEADER_NAME = 'Link';
    private static final String NEXT_PAGE_LINK_IDENTIFIER = 'rel="next"';
    
    global override String getRepoListEndpoint(Boolean isUser, String domain) {

        String placeholder = isUser ?
                            '/users/{0}/repos' :
                            '/orgs/{0}/repos';
        
        return String.format(placeholder, new String[]{domain});
    }


    global override Map<String, String> getRepoListParams(Integer page, Integer pageSize) {
        return this.getPaginationParams(page, pageSize);
    }


    global override GitRepoListResponseModel parseGetReposRequest(Integer page, Integer pageSize, HTTPResponse res) {
        
        String jsonString = res.getBody();

        jsonString = jsonString.replace('"private"', '"privateX"');

        RepoModel[] models = (RepoModel[])JSON.deserialize(jsonString, RepoModel[].class);

        GitRepoModel[] data = new GitRepoModel[]{};

        for (RepoModel repo : models) {
            data.add(new GitRepoModel(
                this.serviceName,
                repo.name,
                repo.description,
                repo.name,
                repo.full_name,
                repo.owner.login,
                repo.owner.login,
                repo.privateX,
                repo.html_url,
                repo.default_branch
            ));
        }
        
        String links = res.getHeader(LINKS_HEADER_NAME);
        Boolean hasNextPage = String.isNotBlank(links) && links.contains(NEXT_PAGE_LINK_IDENTIFIER);

        return new GitRepoListResponseModel(pageSize, page, hasNextPage, data);
    }
    

    global override String getRepoTreeEndpoint(String ownerPath, String repoPath, String path, String branch) {

        String placeholder = '/repos/{0}/{1}/contents/{2}?ref={3}';

        return String.format(placeholder, new String[]{
            ownerPath, repoPath, path, branch
        });
    }


    global override Map<String, String> getRepoTreeParams(Integer page, Integer pageSize) {
        return this.getPaginationParams(page, pageSize);
    }


    global override GitRepoTreeResponseModel parseGetFileTreeRequest(Integer page, Integer pageSize, HTTPResponse res) {
        
        FileModel[] models = (FileModel[])JSON.deserialize(res.getBody(), FileModel[].class);

        GitFileModel[] data = new GitFileModel[]{};

        for (FileModel file : models) {
            data.add(new GitFileModel(
                file.name,
                file.path,
                file.getFileType()
            ));
        }
        
        return new GitRepoTreeResponseModel(pageSize, page, false, data);
    }


    global override String getFileContentEndpoint(String ownerPath, String repoPath, String path, String branch) {

        String placeholder = '/repos/{0}/{1}/contents/{2}?ref={3}';

        return String.format(placeholder, new String[]{
            ownerPath, repoPath, path, branch
        });
    }    
    

    global override Map<String, String> getFileContentHeaders() {

        return new Map<String, String>{
            'Accept' => 'application/vnd.github.VERSION.raw'
        };
    }


    global override GitFileContentResponseModel parseGetFileContentRequest(HTTPResponse res) {
    
        return new GitFileContentResponseModel(res.getBody(), null);
    }
    

    global override String handleError(HTTPResponse res) {

        ErrorModel model = (ErrorModel)JSON.deserialize(res.getBody(), ErrorModel.class);

        return model.message;
    }


    private Map<String, String> getPaginationParams(Integer page, Integer pageSize) {
        
        return new Map<String, String>{
            'page' => String.valueOf(page),
            'per_page' => String.valueOf(pageSize)
        };
    }

    /**
     * *******************************
     * Serializing models
     * *******************************
     */
     
    private class RepoModel {

        String id;
        String name;
        String full_name;
        Boolean privateX;
        String language;
        String description;
        String html_url;
        OwnerModel owner;
        String default_branch;
    }

    private class OwnerModel {

        String id;
        String html_url;
        String login;
    }

    private class ErrorModel {

        String message;
    }


    private class FileModel {

        String type;
        String name;
        String path;
        String sha;

        public GitFileModel.FileType getFileType() {

            switch on this.type {

                when 'file' {
                    return GitFileModel.FileType.FILE;
                }

                when 'dir' {
                    return GitFileModel.FileType.DIRECTORY;
                }

                when else {
                    return GitFileModel.FileType.OTHER;
                }
            }
        }
    }
}
