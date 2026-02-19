# Skitty

Pure bash security scripts

## Downloading

This section will cover how to download and prep skitty scripts to your liking.

### Clone

First clone the repo:
```
git clone https://www.github.com/ntjennings1/skitty.git
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

Then, to run a script every 15 minutes:
```
15 * * * * $SKITTY_HOME/inetcheck.sh
```

## Acknowledgements

```
Noah Jennings
	ntjennings1@gmail.com
	Old Dominion University
```
