import javax.xml.transform.Result;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
            PreparedStatement execStat = connection.prepareStatement(
                    "SET SEARCH_PATH TO parlgov");
            execStat.executeQuery();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // set up sql statements
        String sqlElection =
                "SELECT election.id " +
                        "FROM country JOIN election ON country.id = election.country_id " +
                        "WHERE country.name = ? ORDER BY e_date DESC";

        String sqlCabinet =
                "SELECT cabinet.id " +
                        "FROM cabinet JOIN country " +
                        "ON cabinet.country_id = country.id " +
                        "WHERE country.name = ? " +
                        "AND cabinet.election_id IN (SELECT election.id " +
                        "FROM country JOIN election ON country.id = election.country_id " +
                        "WHERE country.name = ? ORDER BY e_date DESC) " +
                        "ORDER BY cabinet.start_date DESC";

        try {
            // election id generation
            PreparedStatement psElection = connection.prepareStatement(sqlElection);
            psElection.setString(1, countryName);
            ResultSet rsElection = psElection.executeQuery();
            List<Integer> resultElection = new ArrayList<>();
            while (rsElection.next()){
                resultElection.add(rsElection.getInt("id"));
            }

            // cabinet id generation
            PreparedStatement psCabinet = connection.prepareStatement(sqlCabinet);
            psCabinet.setString(1, countryName);
            psCabinet.setString(2, countryName);
            ResultSet rsCabinet = psCabinet.executeQuery();
            List<Integer> resultCabinet = new ArrayList<>();
            while (rsCabinet.next()){
                resultCabinet.add(rsCabinet.getInt("id"));
            }

            return new ElectionCabinetResult(resultElection, resultCabinet);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        return null;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

