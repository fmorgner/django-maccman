from bs4 import BeautifulSoup

class PrettifyMiddleware(object):
    def process_response(self, request, response):
        if response.status_code == 200:
            if response["content-type"].startswith("text/html"):
                beauty = BeautifulSoup(response.content)
                response.content = beauty.prettify()
        return response

