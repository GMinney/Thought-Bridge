<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <%@include file="head.jsp" %>

    </head>


    <body>
        <%@include file="header.jsp" %>
        <main>

            <div class="outer-container">
                <div class="inner-container">
                    <div class="dropdown">
                        <button class="btn btn-secondary dropdown-toggle m-3 p-3" type="button" data-bs-toggle="dropdown" aria-expanded="false">Network</button>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="#">Thought Mainnet</a></li>
                                <li><a class="dropdown-item" href="#">Thought Testnet</a></li>
                                <li><a class="dropdown-item" href="#">Avalanche Mainnet</a></li>
                                <li><a class="dropdown-item" href="#">Avalanche Testnet</a></li>
                            </ul>
                        <div class="input-group p-1 m-1">
                            <button class="btn btn-outline-secondary" type="button" id="button-addon1">From</button>
                            <input type="text" class="form-control" placeholder="" aria-label="Example text with button addon" aria-describedby="button-addon1">
                        </div>
                    </div>
                </div>
            </div>

        </main>
        <%@include file="footer.jsp" %>
    </body>

</html>