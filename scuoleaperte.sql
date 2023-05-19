-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Creato il: Mag 19, 2023 alle 09:07
-- Versione del server: 5.7.34
-- Versione PHP: 8.0.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `scuoleaperte`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `appuntamenti`
--

CREATE TABLE `appuntamenti` (
  `id` float NOT NULL,
  `idEvento` int(11) DEFAULT NULL,
  `idUtente` int(11) DEFAULT NULL,
  `dataPrenotazione` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `appuntamenti`
--

INSERT INTO `appuntamenti` (`id`, `idEvento`, `idUtente`, `dataPrenotazione`) VALUES
(1, 5, 26, '2023-05-18 18:26:18'),
(3, 5, 28, '2023-05-19 08:07:28'),
(6, 6, 29, '2023-05-19 10:22:36');

--
-- Trigger `appuntamenti`
--
DELIMITER $$
CREATE TRIGGER `aumentaPostiDisponibili` AFTER DELETE ON `appuntamenti` FOR EACH ROW BEGIN
UPDATE eventi SET nPartecipanti = nPartecipanti - 1 WHERE id = old.idEvento;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `diminuisciPostiDisponibili` BEFORE INSERT ON `appuntamenti` FOR EACH ROW BEGIN 
DECLARE nP INT;
DECLARE nPa INT;

SELECT numPosti INTO nP 
FROM eventi
WHERE ID = NEW.idEvento;

SELECT nPartecipanti INTO nPa 
FROM eventi 
WHERE ID = new.idEvento;

IF (nP - nPa > 0) THEN
 UPDATE eventi
 SET nPartecipanti = nPartecipanti +1
 WHERE id = NEW.idEvento;
ELSE
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "posti esauriti";
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `calendario`
--

CREATE TABLE `calendario` (
  `data` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `eventi`
--

CREATE TABLE `eventi` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `materia` varchar(100) DEFAULT NULL,
  `data` datetime DEFAULT NULL,
  `idOrganizzatore` int(11) DEFAULT NULL,
  `numPosti` int(11) DEFAULT NULL,
  `durata` int(11) DEFAULT NULL,
  `nPartecipanti` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `eventi`
--

INSERT INTO `eventi` (`id`, `nome`, `materia`, `data`, `idOrganizzatore`, `numPosti`, `durata`, `nPartecipanti`) VALUES
(3, 'Evento', 'CIOAOOOO', '2023-05-25 22:50:00', 25, 4, 60, 0),
(4, 'cdwc', 'cdwc', '2023-05-18 04:56:00', 25, 20, 61, 0),
(5, 'Settebello Evento', 'Festa Granda', '2023-05-20 18:18:00', 26, 2, 120, 2),
(6, 'pigiama party dal fava', 'feston bueo', '2023-05-20 21:30:00', 28, 15, 10229, 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `utenti`
--

CREATE TABLE `utenti` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `cognome` varchar(100) NOT NULL,
  `mail` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `VerifiedAt` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `utenti`
--

INSERT INTO `utenti` (`id`, `nome`, `cognome`, `mail`, `password`, `VerifiedAt`) VALUES
(23, 'luca', 'scala', 'lucascala@blabla', '$2a$11$08M91.016zlKr3s5BL67UOgzsvQNKehEtBBDXCnGOZlAY5PXGpg8.', '2023-05-15'),
(24, 'ale', 'dina', 'aledina@blabla', '$2a$11$e3pBJgo5vWQ8eurKpAACEeHpiu1EfO/IyKZ0Zm13uI/g8wn41Zz1y', '2023-05-15'),
(25, 'Alessandro', 'Dinato', 'alessandro.dinato@gmail.com', '$2a$11$n1wwnwGuANYgRcMzBAn0m.W1H1L.tGYscdNpu/G3yCohczC/MEZGq', '2023-05-17'),
(26, 'Alessandro', 'Dinato', 'alessandro.dinato@hotmail.com', '$2a$11$.7PZrtmPzpJVXW9KBlAZC.natx.C6oZhe0H4x0rZGwSbhmiu4RVaC', '2023-05-18'),
(27, 'Alessandro', 'Favaro', 'ale04fava@gmail.com', '$2a$11$g8j9cLJJW8kTg1JVT/4QS.DgMUdmadfTKVWLoEwyGDO8iXY6GHEUC', NULL),
(28, 'Alessandro', 'Favaro', 'alessandro.favaro@barsanti.edu.it', '$2a$11$wyHRnOGeOdAeIfWrxa56cen.xALYX5OeV3MycQ92tZN0mw6qjl16e', '2023-05-19'),
(29, 'Alessandro', 'Dinato', 'alberto.maggiotto@barsanti.edu.it', '$2a$11$.Nu6zzLlJDm1.6R.3WAZt.gwgNJ9BWFZDKw0zXfKdeKb42mIMK87u', '2023-05-19');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `appuntamenti`
--
ALTER TABLE `appuntamenti`
  ADD PRIMARY KEY (`id`),
  ADD KEY `appuntamenti_FK` (`idEvento`),
  ADD KEY `appuntamenti_FK_1` (`idUtente`);

--
-- Indici per le tabelle `calendario`
--
ALTER TABLE `calendario`
  ADD PRIMARY KEY (`data`);

--
-- Indici per le tabelle `eventi`
--
ALTER TABLE `eventi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `eventi_FK` (`idOrganizzatore`);

--
-- Indici per le tabelle `utenti`
--
ALTER TABLE `utenti`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `mail` (`mail`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `appuntamenti`
--
ALTER TABLE `appuntamenti`
  MODIFY `id` float NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT per la tabella `eventi`
--
ALTER TABLE `eventi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT per la tabella `utenti`
--
ALTER TABLE `utenti`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `appuntamenti`
--
ALTER TABLE `appuntamenti`
  ADD CONSTRAINT `appuntamenti_FK` FOREIGN KEY (`idEvento`) REFERENCES `eventi` (`id`),
  ADD CONSTRAINT `appuntamenti_FK_1` FOREIGN KEY (`idUtente`) REFERENCES `utenti` (`id`);

--
-- Limiti per la tabella `eventi`
--
ALTER TABLE `eventi`
  ADD CONSTRAINT `eventi_FK` FOREIGN KEY (`idOrganizzatore`) REFERENCES `utenti` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
