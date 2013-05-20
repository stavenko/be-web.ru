from django.views.generic import ListView, TemplateView



class ConstructorPage(TemplateView):
    def get(self,req, *k, **kw):
        self.template_name = "constructor/constructor_page.html"
        return self.render_to_response({})
    

