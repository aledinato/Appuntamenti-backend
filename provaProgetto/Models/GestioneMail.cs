using System.Net;
using Microsoft.AspNetCore.Mvc;
using MimeKit;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.DependencyInjection;
using Razor.Templating.Core;
using System.Dynamic;
using MailKit.Net.Smtp;
using MailKit;

namespace provaProgetto.Models
{
    public class GestioneMail
    {
        private GestioneUtente gUtente;

        public GestioneMail(GestioneUtente g) {
            gUtente = g;
        }

        private async Task<string> ConvertView(string viewName, object Tmodel, string baseURL)
        {
            dynamic mymodel = new ExpandoObject();
            mymodel.model = Tmodel;
            mymodel.baseURL = baseURL;
            var html = await RazorTemplateEngine.RenderAsync(viewName, mymodel);
            return html;
        }

        public async Task<bool> SendMailVerificationAsync(int userId, string baseURL)
        {

            Utente utente = gUtente.FindUtente(userId)!;
            var email = new MimeMessage();
            email.From.Add(new MailboxAddress("Alessandro Dinato", "alessandro.dinato@barsanti.edu.it"));
            email.To.Add(new MailboxAddress(utente.nome + utente.cognome, utente.mail));

            email.Subject = "Verification mail";
            email.Body = new TextPart(MimeKit.Text.TextFormat.Html) {
                Text = await ConvertView("Htmls/mailVerification.cshtml", userId, baseURL)
            };

            try
            {
                using (var smtp = new SmtpClient())
                {
                    smtp.Connect("smtp.gmail.com", 587, false);
                    smtp.Authenticate("alessandro.dinato@barsanti.edu.it", "passwordGmailAccount");
                    smtp.Send(email);
                    smtp.Disconnect(true);
                }
            }
            catch (Exception error) {
                return false;
            }	
            return true;
        }
    }
}
