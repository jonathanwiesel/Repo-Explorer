global abstract with sharing class GitHostingService {
    
    /**
     * Parse a success repository fetching request response
     * @param  page     - page asked for
     * @param  pageSize - page size configured
     * @param  res      - response object
     */
    global abstract GitServiceResponseModel parseGetReposRequest(Integer page, Integer pageSize, HTTPResponse res);

    /**
     * Handle errors with the API
     * @param  res - response object
     */
    global abstract GitServiceResponseModel handleError(HttpResponse res);
}