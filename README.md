<p align="center">
	<img src="images/skitty.png" alt="Skitty Logo" width=500>
	<h1 align="center"> Skitty  </h1>
</p>

Pure bash security scripts.

## OS Requirements

```
- Kali Linux 6.18.12-amd64
```

## Scripts

Included scripts give users the option to manipulate the following:

```
- Machine state
- System packages
- Running services
- Environment variables
- Visualizations
```

## Downloading

This section will cover how to download and prep skitty scripts to your liking.

### Clone

First clone the repo:
```
git clone https://www.github.com/ntjennings1/skitty.git $SKITTY_HOME
```

### Permissions

Be sure to reserve all permissions for yourself.
```
chmod 700 ./skitty -R
```

Next, enter the directory of the skitty project:
```
cd $SKITTY_HOME
```
## Executing

Using skitty scripts can be done serveral ways.

### Direct

Skitty scripts can be executed directly like this:
```
./$SKITTY_HOME/inetcheck.sh
```

### Cron

Add scripts to your crontab like this:
```
crontab -e
```

Then, to check if your machine is connected to the internet every 15 minutes:
```
15 * * * * $SKITTY_HOME/inetcheck.sh
```

## Logging

Skitty scripts will automatically log data for themselves and user analysis. Logs can be found here:

```
./$SKITTY_HOME/logs/
```

## Troubleshooting

Users may experience difficulty running some scripts. This section attempts to ease the troubleshooting process.

### Packages

Start by ensuring internet connection:
```
./$SKITTY_HOME/inetcheck.sh
```

Then, install required packages:

```
./$SKITTY_HOME/enstaller.sh
```

Check script output & logs for any errors:

```
cat ./$SKITTY_HOME/logs/enstaller
```

## Acknowledgements

```
Noah Jennings
	ntjennings1@gmail.com
	Virginia Beach, VA
```
