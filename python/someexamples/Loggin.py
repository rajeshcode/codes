import logging 
logging.basicConfig(format='%(asctime)s   %(levelname)s:%(message)s', datefmt='%m/%d/%Y %I:%M:%S %p', level=logging.DEBUG)

logging.debug(' This is Debug Mesg')
logging.info(' This is info msg')
logging.warn('And this, too')
