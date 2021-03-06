global inherited sharing class CalloutManager {
    
    private static final String ENDPOINT_FORMAT = 'callout:{0}{1}';

    /**
     * Build and send an http request based on the specified params
     * @param  endpoint    - endpoint to hit
     * @param  method      - http method to use
     * @param  queryParams - query string paramsters
     * @param  headers     - additional headers
     */
    global static HTTPResponse sendRequest(String namedCredential, String endpoint, String method, Map<String, String> queryParams, Map<String, String> headers) {
        
        endpoint = CalloutManager.getFormattedEndpoint(namedCredential, endpoint);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint + CalloutManager.getQueryStringParams(endpoint, queryParams));
        req.setMethod(method);

        CalloutManager.setHeaders(req, headers);

        Http http = new Http();
        return http.send(req);
    }


    /**
     * Obtain query string params to append to the endpoint
     * @param  endpoint    - endpoint to hit
     * @param  queryParams - params to add
     */
    private static String getQueryStringParams(String endpoint, Map<String, String> queryParams) {

        String[] parts = new String[]{};

        if (queryParams != null) {

            for (String key : queryParams.keySet()) {
                parts.add(key + '=' + queryParams.get(key));
            }
        }

        return parts.isEmpty() ? '' : 
                ((endpoint.contains('?') ? '&' : '?' ) + String.join(parts, '&'));
    }


    /**
     * Apply additional request headers
     * @param  req     - request object to apply the records
     * @param  headers - headers to apply
     */
    private static void setHeaders(HttpRequest req, Map<String, String> headers) {

        if (headers != null) {

            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
    }

    /**
     * Create formatted endpoint based on a named credentials
     * @param  namedCredential - named credential name
     * @param  endpoint        - partial endpoint
     */
    private static String getFormattedEndpoint(String namedCredential, String endpoint) {

        return String.format(ENDPOINT_FORMAT, new String[]{namedCredential, endpoint});
    }
}
