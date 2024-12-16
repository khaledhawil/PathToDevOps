# select your image 
FROM alpine

# run a echo command after the container running 
CMD ["echo", "Hello From Dockerfile","Aadd CMD"]

---
    
FROM ubuntu 

RUN apt-get update -y  && apt-get upgrade -y 

CMD ["echo","Hello from $USER container"]



--- 

################ CMD #####################333
FROM ubuntu 
RUN apt-get update  &&  apt-get install -y \
    git \
    vim    


CMD ["echo","Hello From git container with  installed vim and curl and net-tolls"]

---


########################################################
################ Dem DockerFile part2 ##################
#################################################3######




########### ENTRYPOINT ####################33

FROM ubuntu 

RUN apt-get update && apt-get install -y iputils-ping 

ENTRYPOINT ["echo"]

---

##### EXPOSE
FROM nginx 

EXPOSE 80


---

## COPY 

FROM ubuntu 
COPY test.txt . 


-----
##### WORKDIR 
FROM ubuntu
WORKDIR /docker 
RUN echo "Hello from docker dir" > dokcer.txt
WORKDIR container
RUN echo "Hello From container Dir" > cont.txt 
---

######## ENV 
FROM ubuntu 
RUN apt-get update && apt-get install -y iputils-ping 

ENV name=khaled env1=ping env2=8.8.8.8 
CMD ${env1} ${env2}
#  MAINTAINER 
FROM ubuntu
MAINTAINER 7awil  
RUN apt-get update 
CMD ["echo", "Hello from 7awil host "]