from django.contrib.auth import logout, login
from django.core.urlresolvers import reverse_lazy

from django.views.generic.base import TemplateView, RedirectView
from django.views.generic.edit import FormView
from .models import Domain, Mailbox, UserProfile
from .forms import UserProfileAuthenticationForm


class IndexView(TemplateView):
    template_name = 'maccman/index.html'

    def get_context_data(self, **kwargs):
        context = super(IndexView, self).get_context_data(**kwargs)
        return context


class LoginView(FormView):

    template_name = 'maccman/login.html'
    form_class = UserProfileAuthenticationForm
    index = reverse_lazy('maccman:index')

    def get_context_data(self, **kwargs):
        context = super(LoginView, self).get_context_data(**kwargs)
        context['next'] = self.request.GET.get('next', self.index)
        return context

    def get_success_url(self):
        return self.request.POST.get('next', self.index)

    def form_valid(self, form):
        login(self.request, form.get_user())
        return super(LoginView, self).form_valid(form)


class LogoutView(RedirectView):

    permanent = False
    query_string = False
    pattern_name = 'maccman:index'

    def get_redirect_url(self, *args, **kwargs):
        logout(self.request)
        return super(LogoutView, self).get_redirect_url(*args, **kwargs)



