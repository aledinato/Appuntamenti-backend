using System;
using System.Configuration;
using System.Reflection.Metadata.Ecma335;
using Dapper;
using MySql.Data.MySqlClient;
using provaProgetto.Dipendenze;
using provaProgetto.Models;

namespace provaProgetto.Models
{
	public class GestioneDati: IGestioneDati
	{
		private string s;
        public GestioneDati(IConfiguration configuration)
		{
            s = configuration.GetConnectionString("progettoConnection")!;
        }



		//appuntamenti
        public List<Appuntamento> futureBookings(int userId)
        {
            var today = DateTime.Now;
            var app = new DateTime(today.Year, today.Month, today.Day);
            using var con = new MySqlConnection(s);
            var query = "SELECT appuntamenti.* FROM appuntamenti " +
                "INNER JOIN eventi on appuntamenti.idEvento=eventi.id WHERE data >= @today AND appuntamenti.idUtente=@userId";
            var param = new
            {
                today = app,
                userId = userId
            };
            return con.Query<Appuntamento>(query, param).ToList();
        }
        public List<Appuntamento> pastBookings(int userId)
        {
            var today = DateTime.Now;
            var app = new DateTime(today.Year, today.Month, today.Day);
            using var con = new MySqlConnection(s);
            var query = "SELECT appuntamenti.* FROM appuntamenti " +
                "INNER JOIN eventi on appuntamenti.idEvento=eventi.id WHERE data < @today AND appuntamenti.idUtente=@userId";
            var param = new
            {
                today = app,
                userId = userId
            };
            return con.Query<Appuntamento>(query, param).ToList();
        }
        public List<Appuntamento> ListaAppuntamenti(int userId)
        {
            using var con = new MySqlConnection(s);
            var query ="SELECT * from appuntamenti WHERE idUtente = @userId";
            var param = new
            {
                userId = userId
            };
            return con.Query<Appuntamento>(query, param).ToList();
        }
        public Appuntamento? GetAppuntamento(int id)
        {
            using var con = new MySqlConnection(s);
            var query = "SELECT * from appuntamenti WHERE id=@idApp";
            var param = new
            {
                idApp = id
            };
            return con.Query<Appuntamento>(query, param).FirstOrDefault();
        }

        public Appuntamento? GetAppuntamento(int userId,int eventId)
        {
            using var con = new MySqlConnection(s);
            var query = "SELECT * from appuntamenti WHERE appuntamenti.idUtente=@userId AND appuntamenti.idEvento = @eventId";
            var param = new
            {
                userId = userId,
                eventId = eventId
            };
            return con.Query<Appuntamento>(query, param).FirstOrDefault();
        }

        public int InserisciAppuntamentoUser(int idEvento, Utente u)
        {
            if (GetAppuntamento(u.id, idEvento) == null)
            {
                using var con = new MySqlConnection(s);
                var query = @"INSERT INTO appuntamenti(idEvento, idUtente, dataPrenotazione) VALUES(@idEv,@idUser,@data)";
                var param = new
                {
                    idEv = idEvento,
                    idUser = u.id,
                    data = DateTime.Now.ToString("yyyyMMdd") + "T" + DateTime.Now.ToString("HHmmss"),
                };
                //0001-01-01 00:00:00
                Evento evento = GetEvento(idEvento)!;
                if (evento.nPartecipanti + 1 > evento.numPosti)
                    return 1;//posti finiti

                try
                {
                    con.Execute(query, param);
                    return 0;//ok
                }
                catch (Exception error)
                {
                    return 3;//errore generale
                }
            }
            else {
                return 2;//utente già iscritto
            }
        }
        public bool DeleteAppuntamento(int id)
        {
            using var con = new MySqlConnection(s);
            var query = "DELETE from appuntamenti WHERE id=@idAppuntamento";
            var param = new { idAppuntamento = id };
            try
            {
                con.Execute(query, param);
                return true;
            }
            catch(Exception error)
            {
                return false;
            }
        }
        public bool DeleteAllBookings(int id)
        {
            using var con = new MySqlConnection(s);
            var query = "DELETE from appuntamenti WHERE idUtente=@userId";
            var param = new { userId = id };
            try
            {
                con.Execute(query, param);
                return true;
            }
            catch
            {
                return false;
            }
        }


        //eventi
        public List<Evento> ListaEventi(int id)
        {
            using var con = new MySqlConnection(s);
            var query = "SELECT * from eventi WHERE idOrganizzatore = @userId";
            var param = new
            {
                userId = id
            };
            return con.Query<Evento>(query, param).ToList();
        }
        public Evento? GetEvento(int id)
        {
            using var conn = new MySqlConnection(s);
            var query = "SELECT * from eventi WHERE id=@idEvento";
            var param = new
            {
                idEvento = id
            };
            return conn.Query<Evento>(query, param).FirstOrDefault();
        }
        public bool DeleteEvento(int id)
        {
            using var con = new MySqlConnection(s);
            var query = "DELETE from eventi WHERE id=@idEvento";
            var param = new { idEvento = id };
            try
            {
                con.Execute(query, param);
                return true;
            }
            catch
            {
                return false;
            }
        }
        public bool UpdateEvento(Evento e)
        {
            using var con = new MySqlConnection(s);

            var query = "UPDATE eventi SET nome=@name,materia=@mat,data=@date,idOrganizzatore=@idOrd,numPosti=@nPosti,durata=@dur,nPartecipanti=@partecipanti "+
                "WHERE id=@idEvento";
            var param = new
            {
                idEvento=e.id,
                name = e.nome,
                mat = e.materia,
                date = e.data,
                idOrd = e.idOrganizzatore,
                nPosti = e.numPosti,
                dur = e.durata,
                partecipanti = e.nPartecipanti

            };
            try
            {
                con.Execute(query, param);
                return true;
            }
            catch(Exception error)
            {
                return false;
            }
        }
        public bool InserisciEvento(Evento e)
        {
            using var con = new MySqlConnection(s);
            var query = @"INSERT INTO eventi(nome,materia,data,idOrganizzatore,numPosti,durata,nPartecipanti) VALUES(@name,@mat,@date,@idOrg,@nPosti,@dur,@partecipanti)";
            var param = new
            {
                name = e.nome,
                mat = e.materia,
                date = e.data,
                idOrg = e.idOrganizzatore,
                nPosti = e.numPosti,
                dur = e.durata,
                partecipanti=e.nPartecipanti
            };
            try
            {
                con.Execute(query, param);
                return true;
            }
            catch(Exception error){ return false;}
        }


        //participants

        public List<Partecipante> ListPartecipants(int id)
        {
            using var con = new MySqlConnection(s);
            var query = "SELECT appuntamenti.id, utenti.nome, utenti.cognome, utenti.mail FROM utenti " +
                "INNER JOIN appuntamenti on utenti.id = appuntamenti.idUtente where idEvento =@idEvento";
            var param = new { idEvento = id };
            return con.Query<Partecipante>(query, param).ToList();
        }

    }
}

